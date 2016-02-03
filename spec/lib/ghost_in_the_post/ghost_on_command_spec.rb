require "spec_helper"
require 'mail'

module GhostInThePost
  describe GhostOnCommand do
    let(:instance) { SomeMailer.new(Mail.new(to: "foo@example.com", from: "me@example.com")) }
    let(:email) {instance.mail}

    describe "#ghost" do
      it "Should return a Message" do
        expect(email.ghost).to be_a(Mail::Message)
      end
      it "should create a MailGhost" do
        email.included_scripts = ["test"]
        email.ghost_timeout = 1000
        email.ghost_wait_event = "test"
        expect(MailGhost).to receive(:new).with(email, 1000, "test", ["test"]).and_call_original
        email.ghost
      end
      it "should apply included scripts to the mail ghost" do
        expect(email).to receive(:included_scripts).and_call_original
        email.ghost
      end
    end

  end
end

