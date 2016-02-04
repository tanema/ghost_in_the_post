require "spec_helper"
require 'mail'

module GhostInThePost
  describe Automatic do
    let(:email) { Mail.new(to: "foo@example.com", from: "me@example.com") }
    let(:instance) { AutoMailer.new(email) }
    describe "#mail" do
      it "should return an email" do
        expect(instance.mail).to be_kind_of(Mail::Message)
      end
      it "should return an email extended with GhostOnCommand and GhostOnDelivery" do
        expect(instance.mail).to be_kind_of(GhostOnDelivery)
      end
    end
  end
end
