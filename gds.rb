require 'sinatra'
require 'ralyxa'

post '/alexa' do
  puts '------'
  puts request.inspect
  puts '------'
  puts request.body.read
  puts '------'
  request.body.rewind
  Ralyxa::Skill.handle(request)
end

get '/_status' do
  'Running'
end
