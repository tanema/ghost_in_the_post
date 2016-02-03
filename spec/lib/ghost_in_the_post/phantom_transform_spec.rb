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
      it "should set html" do
        pt = PhantomTransform.new(html, nil, nil, included_scripts)
        expect(pt.instance_variable_get(:@html)).to eq(html)
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
      it "should set included_scripts" do
        pt = PhantomTransform.new(html, nil, nil, included_scripts)
        expect(pt.instance_variable_get(:@included_scripts)).to eq(included_scripts)
      end
      it "should default included_scripts to an array" do
        pt = PhantomTransform.new(html, nil, nil, nil)
        expect(pt.instance_variable_get(:@included_scripts)).to eq([])
      end
    end

    describe "#transform" do
      let(:html_path) {"/this/is/htmlpath"}
      let(:js_path) {"/this/is/js_path"}

      before :each do
        allow(IO).to receive(:popen)
        allow(Rails.application).to receive(:assets){{"application.js": js}}
      end

      it "should create a temp file for the html" do
        file = Object.new
        expect(subject).to receive(:html_file){file}
        allow(file).to receive(:path){html_path}
        expect(file).to receive(:unlink)
        subject.transform
      end

      it "should create a temp file for the js" do
        file = Object.new
        expect(subject).to receive(:js_file){file}
        allow(file).to receive(:path){js_path}
        expect(file).to receive(:unlink)
        subject.transform
      end

      it "should call IO.popen with arguments" do
        html_file = Object.new
        expect(subject).to receive(:html_file){html_file}
        allow(html_file).to receive(:path){html_path}
        allow(html_file).to receive(:unlink)

        js_file = Object.new
        expect(subject).to receive(:js_file){js_file}
        allow(js_file).to receive(:path){js_path}
        allow(js_file).to receive(:unlink)

        expect(IO).to receive(:popen).with([
          GhostInThePost.phantomjs_path, 
          GhostInThePost::PhantomTransform::PHANTOMJS_SCRIPT, 
          html_path,
          GhostInThePost.remove_js_tags.to_s,
          js_path,
          "1000",
          "ghost_in_the_post:done",
        ])

        subject.transform
      end

      it "should return the result of IO.popen with arguments" do
        allow(IO).to receive(:popen) {"this is the end"}
        expect(subject.transform).to eq("this is the end")
      end

      it "should unlink file even if there was an error" do
        html_file = Object.new
        expect(subject).to receive(:html_file){html_file}
        allow(html_file).to receive(:path){html_path}
        expect(html_file).to receive(:unlink)

        js_file = Object.new
        expect(subject).to receive(:js_file){js_file}
        allow(js_file).to receive(:path){js_path}
        expect(js_file).to receive(:unlink)

        allow(IO).to receive(:popen) {raise ArgumentError}

        expect{subject.transform}.to raise_error ArgumentError
      end

    end
  end
end

