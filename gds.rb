require 'sinatra'
require 'ralyxa'

require_relative './lib/session'

Ralyxa.configure do |c|
  c.validate_requests = false # this is required as the gem is missing a rewind once the body is read
end

post '/alexa' do
  unless ENV['RACK_ENV'] == 'test'
    puts '------'
    puts request.body.read
    puts '------'
    request.body.rewind
  end

  Ralyxa::Skill.handle(request)
end

get '/_status' do
  'Running'
end
