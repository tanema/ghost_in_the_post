require "spec_helper"

module GhostInThePost

  describe JsInline do
    let(:html){"<html><head><script></script></head><body><div id='test'></div></body></html>"}
    let(:html_without_script){"<html><head></head><body><div id='test'></div></body></html>"}
    let(:js){"(function(){document.getElementById('test').innerHTML='complete';})()"}
    let(:html_with_js){"<html><head><script></script></head><body><div id='test'></div><script>#{js}</script></body></html>"}
    let(:included_scripts){["application.js"]}
    subject {JsInline.new(html, included_scripts)}

    describe "#initialize" do
      it "should assign html" do
        expect(Nokogiri::HTML).to receive(:parse)
        JsInline.new(html, included_scripts)
      end
      it "should set included_scripts" do
        ji = JsInline.new(html, included_scripts)
        expect(ji.instance_variable_get(:@included_scripts)).to eq(included_scripts)
      end
      it "should default included_scripts to an array" do
        ji = JsInline.new(html)
        expect(ji.instance_variable_get(:@included_scripts)).to eq([])
      end
    end

    describe "#inline" do
      before :each do
        allow(subject).to receive(:find_asset_in_pipeline).with("application.js").and_return(js)
      end

      it "should inline js" do
        subject.inline
        expect(subject.html).to include(js)
        expect(subject.html).to include("<script id=\"#{JsInline::SCRIPT_ID}\"")
      end
    end

    describe "#remove_all_script" do
      it "should remove all js" do
        subject.remove_all_script
        expect(subject.html).not_to include("<script")
      end
    end

    describe "#remove_inlined" do
      it "should remove just the inlined js" do
        subject.remove_inlined
        expect(subject.html).to include("<script")
        expect(subject.html).not_to include("<script id=\"#{JsInline::SCRIPT_ID}\"")
      end
    end

    describe "#html=" do
      it "should parse the html" do
        subject.html #initialize first so that it only receives once
        expect(Nokogiri::HTML).to receive(:parse)
        subject.html = ""
      end
    end

    describe "#html" do
      it "should return a string" do
        expect(subject.html).to be_a(String)
      end
    end

  end

end
