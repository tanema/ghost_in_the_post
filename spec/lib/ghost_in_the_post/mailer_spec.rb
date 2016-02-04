require "spec_helper"
require 'mail'

module GhostInThePost
  describe Mailer do
    let(:email) { Mail.new(to: "foo@example.com", from: "me@example.com") }
    let(:instance) { SomeMailer.new(email) }
    describe "#include_script" do
      it "should add to include scripts" do
        instance.include_script "test.js"
        expect(instance.instance_variable_get(:@included_scripts)).to eq(["test.js"])
        instance.include_script "foo.js"
        expect(instance.instance_variable_get(:@included_scripts)).to eq(["test.js", "foo.js"])
      end
    end
    describe "#set_ghost_timeout" do
      it "should set the timeout" do
        instance.set_ghost_timeout 42
        expect(instance.instance_variable_get(:@ghost_timeout)).to eq(42)
      end
    end
    describe "#set_ghost_wait_event" do
      it "should set the wait_event" do
        instance.set_ghost_wait_event "doo:doo"
        expect(instance.instance_variable_get(:@ghost_wait_event)).to eq("doo:doo")
      end
    end
    describe "#mail" do
      it "should return an email" do
        expect(instance.mail).to be_kind_of(Mail::Message)
      end
      it "should return an email extended with GhostOnCommand and GhostOnDelivery" do
        expect(instance.mail).to be_kind_of(GhostOnCommand)
      end
      it "should have set the emails variables" do
        expect(email).to receive(:included_scripts=)
        expect(email).to receive(:ghost_timeout=)
        expect(email).to receive(:ghost_wait_event=)
        instance.mail
      end
    end
  end
end
