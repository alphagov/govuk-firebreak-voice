require 'sinatra'
require 'ralyxa'

Ralyxa.configure do |c|
  c.validate_requests = false # this is required as the gem is missing a rewind once the body is read
end

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
