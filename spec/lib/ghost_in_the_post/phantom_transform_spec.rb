require "spec_helper"

module GhostInThePost
  describe PhantomTransform do
    let(:html){"<html><head><script></script></head><body><div id='test'></div></body></html>"}
    let(:js){"(function(){document.getElementById('test').innerHTML='complete';})()"}
    let(:included_scripts){["application.js"]}
    subject {PhantomTransform.new(html, nil, nil,included_scripts)}

    before :each do
      GhostInThePost.config = {phantomjs_path: "this/is/path"}
      allow_message_expectations_on_nil
    end

    describe "#initialize" do
      it "should create a new JSInline" do
        expect(JsInline).to receive(:new).with(html, included_scripts).and_call_original
        t = PhantomTransform.new(html, nil, nil,included_scripts)
        expect(t.instance_variable_get(:@inliner)).to be_a(JsInline)
      end
      it "should set the timeout" do
        pt = PhantomTransform.new(html, 45, nil, included_scripts)
        expect(pt.instance_variable_get(:@timeout)).to eq(45)
      end
      it "should set the default timeout if none given" do
        pt = PhantomTransform.new(html, nil, nil, included_scripts)
        expect(pt.instance_variable_get(:@timeout)).to eq(GhostInThePost.timeout)
      end
      it "should set the wait event" do
        pt = PhantomTransform.new(html, nil, "my wait", included_scripts)
        expect(pt.instance_variable_get(:@wait_event)).to eq("my wait")
      end
      it "should set the default wait event if none given" do
        pt = PhantomTransform.new(html, nil, nil, included_scripts)
        expect(pt.instance_variable_get(:@wait_event)).to eq(GhostInThePost.wait_event)
      end
    end

    describe "#transform" do
      before :each do
        @inliner = JsInline.new(html)
        allow(@inliner).to receive(:inline)
        allow(JsInline).to receive(:new){@inliner}
      end

      it "should call IO.popen with arguments" do
        expect(IO).to receive(:popen).with([
          GhostInThePost.phantomjs_path, 
          GhostInThePost::PhantomTransform::PHANTOMJS_SCRIPT, 
          @inliner.html,
          "1000",
          "ghost_in_the_post:done",
        ]).and_return html
        subject.transform
      end

      it "should check if there is an error from phantom" do
        allow(IO).to receive(:popen).and_return PhantomTransform::ERROR_TAG
        expect{subject.transform}.to raise_error GhostJSError
      end

      it "should remove script tags if config set" do
        GhostInThePost.config = {phantomjs_path: "this/is/path", remove_js_tags: true}
        allow(IO).to receive(:popen).and_return ""
        expect(@inliner).to receive(:remove_all_script)
        subject.transform
      end

    end
  end
end

