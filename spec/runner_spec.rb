require 'pry-byebug'
require "spec_helper"
require_relative "../models/runner"
require_relative "../models/deaf_grandma"

describe "Runner" do
  let(:program) { Runner.new }

  context "rest client" do

    it "is an attribute on Runner, containing a connection to a twitter rest client" do
      expect(program.rest_client).to be_a(Twitter::REST::Client)
    end

    it "belongs to user handle 'deaf_grandma'" do
      expect(program.rest_client.user.screen_name).to eq('deaf_grandma')
    end
  end

  it "has an attribute containing a connection to a twitter streaming client" do
    expect(program.streaming_client).to be_a(Twitter::Streaming::Client)
  end

  describe "#process_tweet" do
    context "incoming tweet is all caps" do
      let(:all_caps_tweet) { program.rest_client.status(705888328093073409) }

      it "updates the rest client with @deaf_grandma's appropriate response" do
        program.process_tweet(all_caps_tweet)

        expect(program.rest_client.user_timeline.first.text).to include(DeafGrandma::RESPONSES.first)
      end
    end
  end
end
