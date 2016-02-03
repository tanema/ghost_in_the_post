require 'spec_helper'
require 'mail'

module GhostInThePost
  describe MailGhost do
    let(:email) { Mail.new }
    let(:included_scripts) { ["application.js"] }
    subject(:ghost) { MailGhost.new(email, included_scripts) }

    it "takes an email and options" do
      expect(ghost.email).to eq(email)
      expect(ghost.included_scripts).to eq(included_scripts)
    end

    context "with an plaintext email" do
      let(:email) do
        Mail.new do
          body "Hello world"
        end
      end

      it "returns the email without doing anything" do
        expect(ghost.execute).to eq(email)
        expect(email.html_part).to be_nil
        expect(email.body.decoded).to eq("Hello world")
      end

      it "works fine when given nil included_scripts" do
        ghost = MailGhost.new(email, nil)
        expect { ghost.execute }.to_not raise_error
        expect(ghost.included_scripts).to eq([])
      end
    end

    context "with an HTML email" do
      let(:html) { "<h1>Hello world!</h1>" }
      let(:email) do
        html_string = html
        Mail.new do
          content_type 'text/html; charset=UTF-8'
          body html_string
        end
      end

      it "adjusts the html part using Roadie" do
        document = double "A document", transform: "transformed HTML"
        expect(PhantomTransform).to receive(:new).with(html, included_scripts).and_return document
        ghost.execute
        expect(email.body.decoded).to eq("transformed HTML")
      end
    end

    context "with an multipart email" do
      let(:html) { "<h1>Hello world!</h1>" }
      let(:email) do
        html_string = html
        Mail.new do
          text_part { body "Hello world" }
          html_part { body html_string }
        end
      end

      it "adjusts the html part using Roadie" do
        document = double "A document", transform: "transformed HTML"
        expect(PhantomTransform).to receive(:new).with(html, included_scripts).and_return document
        ghost.execute
        expect(email.html_part.body.decoded).to eq("transformed HTML")
      end
    end

  end
end

