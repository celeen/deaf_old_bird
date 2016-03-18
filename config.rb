require 'pathname'
# require 'sinatra'
require 'twitter'
require 'yaml'

APP_ROOT = Pathname.new(File.expand_path('../', __FILE__))

APP_NAME = APP_ROOT.basename.to_s

env_config = YAML.load_file(APP_ROOT.join('environment.yaml'))

env_config.each do |key, value|
  ENV[key] = value
end

CLIENT = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_KEY"]
  config.consumer_secret     = ENV["CONSUMER_SECRET"]
  config.access_token        = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
end

puts ENV


# configure do
