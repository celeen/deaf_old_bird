require 'pony'
require 'logger'
require_relative 'deaf_grandma'
require_relative '../config'

class Runner
  attr_reader :logger, :grammy, :rest_client, :streaming_client

  def initialize
    file = File.open(APP_ROOT + 'log.txt', File::WRONLY | File::APPEND)
    @logger = Logger.new(file)
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

  def start
    streaming_client.user do |incoming|
      case incoming
      when Twitter::Tweet
        process_tweet(incoming)
        logger.info("processed incoming tweet(#{incoming.class}) id: #{incoming.id}")
      when Twitter::Streaming::StallWarning
        body = package_warning(incoming)
        send_mail(ENV['ME'], body)
        logger.warn("received warning: #{incoming.message}, #{incoming.percent_full}")
      else
        send_mail(ENV["ME"], "unexpected thing occurred in #{APP_NAME}: #{incoming.class}")
        logger.info("Received unexpected object or message: #{incoming.class}")
      end
    end
  end

  def process_tweet(incoming)
    response = "@#{incoming.user.screen_name} #{grammy.build_response_to(incoming.text)}"
    logger.info(response)
    rest_client.update(response, :in_response_to_status_id => incoming.id)
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

