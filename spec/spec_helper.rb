$LOAD_PATH << File.expand_path('./')
require 'gds'
require 'rack/test'
require 'rspec'
require 'pry'

ENV['RACK_ENV'] = 'test'

set :raise_errors, true
set :show_exceptions, false

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

module JSONMixin
  def load_json(filename)
    File.read("./spec/requests/#{filename}.json")
  end
end

RSpec.configure do |c|
  c.include RSpecMixin
  c.include JSONMixin
end
