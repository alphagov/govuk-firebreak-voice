source 'https://rubygems.org'
ruby '2.3.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'ralyxa', github: 'dwhenry/ralyxa', branch: 'add-dialog_handling'
gem 'sinatra'
gem 'pry-byebug'
