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

helpers do
  def in_paragraphs(text)
    @text.split("\n\n").map do |paragraph|
      "<p>#{paragraph}</p>"
    end.join
  end
end

get "/show/:name" do
  params[:name]
end

not_found do
  redirect "/"
end
