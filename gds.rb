require 'sinatra'
require 'ralyxa'

post '/alexa' do
  Ralyxa::Skill.handle(request)
end

get '/_status' do
  'Running'
end
