require "spec_helper"
require_relative "../models/deaf_grandma"

describe "DeafGrandma" do
  let(:grammy) { DeafGrandma.new }

  describe "#build_response_to" do
    context "with all caps input" do
      it "outputs one of the provided sample responses" do
        expect(DeafGrandma::RESPONSES).to include(grammy.build_response_to("HI THERE GRANDMA"))
      end

      context "containing 'BYE'" do
        it "outputs the expected farewell string" do
          expect(grammy.build_response_to("GOODBYE GRANDMA!")).to include("BYE")
        end
      end
    end

    context "non caps input" do
      it "outputs expected rejection message" do
        expect(grammy.build_response_to("sup grams")).to eq("WHAT WAS THAT???? SPEAK UP!!!")
      end
    end
  end
end
