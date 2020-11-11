require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do
  @table_of_contents = File.readlines('data/toc.txt')
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  redirect "/" unless (1..@table_of_contents.size).include?(number)

  @title = "Chapter #{number}: #{@table_of_contents[number - 1]}"
  @text = File.read("data/chp#{number.to_s}.txt")

  erb :chapter
end

get "/search" do
  @results = find_matching_chapters(params['query']) unless !params['query']
  erb :search
end

helpers do
  def in_paragraphs(text)
    @text.split("\n\n").each_with_index.map do |paragraph, index|
      "<p id='paragraph#{index}'>#{paragraph}</p>"
    end.join
  end

  def each_chapter
    @table_of_contents.each_with_index do |chapter_file_name, chapter_number|
      chapter_number += 1
      text = File.read("data/chp#{chapter_number}.txt")
      yield chapter_file_name, chapter_number, text if block_given?
    end
  end

  def find_matching_chapters(query)
    results = []
    each_chapter do |name, number, text|
      matching_paragraphs = {}
      text.split("\n\n").each_with_index do |paragraph, index|
        matching_paragraphs[index] = paragraph if paragraph.include?(query)
      end
      results << { name: name, number: number, paragraphs: matching_paragraphs } if matching_paragraphs.any?
    end
    results
  end

  def bold_phrase(text, phrase)
    replacement = "<strong>" + phrase + "</strong>"
    text.gsub(phrase, replacement)
  end
end

not_found do
  redirect "/"
end
