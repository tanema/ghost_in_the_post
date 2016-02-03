require "spec_helper"
require 'mail'

module GhostInThePost
  describe Mailer do
    let(:email) { Mail.new(to: "foo@example.com", from: "me@example.com") }
    let(:instance) { AutoMailer.new(email) }

    describe "#include_script" do

      it "should add to include scripts" do
        instance.include_script "test.js"
        expect(instance.included_scripts).to eq(["test.js"])
      end
    end

    describe "#mail" do
      it "should return an email" do
        expect(instance.mail).to be_kind_of(Mail::Message)
      end

      it "should return an email extended with GhostOnCommand and GhostOnDelivery" do
        expect(email).to receive(:extend).with(GhostOnCommand).and_call_original
        expect(email).to receive(:extend).with(GhostOnDelivery).and_call_original
        mail = instance.mail
        expect(mail).to be_kind_of(GhostOnCommand)
        expect(mail).to be_kind_of(GhostOnDelivery)
      end

      it "should have set the emails included scripts" do
        email.extend GhostOnCommand
        expect(email).to receive(:included_scripts=).with(nil).and_call_original
        instance.mail
      end
    end

  end
end
