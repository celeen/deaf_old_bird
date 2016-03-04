# require 'sinatra'
require 'pony'
require_relative 'models/deaf_grandma'
require_relative 'config'

class Runner
  def initialize
    @grammy = DeafGrandma.new

    @rest_client =
      Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["CONSUMER_KEY"]
        config.consumer_secret     = ENV["CONSUMER_SECRET"]
        config.access_token        = ENV["ACCESS_TOKEN"]
        config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
      end

    @streaming_client =
      Twitter::Streaming::Client.new do |config|
        config.consumer_key        = ENV["CONSUMER_KEY"]
        config.consumer_secret     = ENV["CONSUMER_SECRET"]
        config.access_token        = ENV["ACCESS_TOKEN"]
        config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
      end
  end
  # check for incoming tweets, and collect them, to put them in a queue
  def start
    @streaming_client.user do |incoming|
      case incoming
      when Twitter::Tweet
        # process the thing-- I don't expect incoming to ever fall behind too terribly much
        process_tweet(incoming)
      when Twitter::Streaming::StallWarning
        body = package_warning(incoming)
        send_mail('celeenrusk@gmail.com', body)
      else
        send_mail(ME, "unexpected thing occurred in #{APP_NAME}: #{object.class}"
        #log the class of the thing that came in, and email me?
      end
    end
  end

  def process_tweet(incoming)
    response = "@#{incoming.user.screen_name} #{@grammy.build_response_to(incoming.text)}"
    p response
    @rest_client.update(response, :in_response_to_status_id => incoming.id)
  end

  def send_mail(to, body)
    Pony.mail(:to => to,
              :from => 'deaf_grandma@celeen.info',
              :body => body,
              :via => :smtp,
              :via_options => {
                :address => 'mail.gandi.net',
                :port => '25',
                :user_name => 'deaf_grandma@celeen.info',
                :password => ENV["SMTP_PASSWORD"],
                :authentication => :plain,
                :domain => 'celeen.info',
              }
             )
  end

  def package_warning(warning_object)
    warning = <<-ST
    PLEASE to be aware that you have received a Stall Warning from your Twitter Streaming API client in the #{APP_NAME} app.
    Warning:
    ID: #{warning_object.id},
    CODE: #{warning_object.code},
    MESSAGE: #{warning_object.message},
    PERCENT_FULL: #{warning_object.percent_full}
    ST

    warning
  end
end

program = Runner.new
program.start
