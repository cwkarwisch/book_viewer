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
  @results = search_results(params) unless !params['query']
  erb :search
end

helpers do
  def in_paragraphs(text)
    index = -1
    @text.split("\n\n").map do |paragraph|
      index += 1
      "<p id='#{index}'>#{paragraph}</p>"
    end.join
  end

  def extract_chapter_number(chapter_file_name)
    match = chapter_file_name.match(/[0-9]+/)
    if match
      match[0]
    else
      nil
    end
  end

  def extract_chapter_name(chapter_file_name)
    number = extract_chapter_number(chapter_file_name).to_i
    @table_of_contents[number - 1]
  end

  def find_matching_chapters(query)
    results = []
    Dir.entries("data").each do |chapter|
      next if File.directory?(chapter)
      chapter_hash = { name: extract_chapter_name(chapter),
      number: extract_chapter_number(chapter),
      paragraphs: [] }
      match_found = false
      text = File.read("data/#{chapter}")
      text.split("\n\n").each_with_index do |paragraph, index|
        if paragraph.include?(query)
          chapter_hash[:paragraphs] << { text: paragraph,
                                         index: index }
          results << chapter_hash unless match_found == true
          match_found = true
        end
      end
    end
    results
  end

  def search_results(params)
    results = []
    query = params['query']
    find_matching_chapters(query)
  end

  def bold_phrase(text, phrase)
    replacement = "<strong>" + phrase + "</strong>"
    text.gsub(phrase, replacement)
  end
end

not_found do
  redirect "/"
end
