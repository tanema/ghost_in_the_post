require "spec_helper"

module GhostInThePost
  describe PhantomTransform do
    let(:html){"<html><head><script></script></head><body><div id='test'></div></body></html>"}
    let(:js){"(function(){document.getElementById('test').innerHTML='complete';})()"}
    let(:included_scripts){["application.js"]}
    subject {PhantomTransform.new(html, included_scripts)}

    before :each do
      GhostInThePost.config = {phantomjs_path: "this/is/path"}
      allow_message_expectations_on_nil
    end

    describe "#initialize" do
      it "should set html" do
        pt = PhantomTransform.new(html, included_scripts)
        expect(pt.instance_variable_get(:@html)).to eq(html)
      end
      it "should set included_scripts" do
        pt = PhantomTransform.new(html, included_scripts)
        expect(pt.instance_variable_get(:@included_scripts)).to eq(included_scripts)
      end
      it "should default included_scripts to an array" do
        pt = PhantomTransform.new(html, nil)
        expect(pt.instance_variable_get(:@included_scripts)).to eq([])
      end
    end

    describe "#transform" do

      before :each do
        allow(IO).to receive(:popen)
      end

      context "with included_scripts" do
        let(:path) {"/this/is/path"}

        before :each do
          allow(IO).to receive(:popen)
          allow(Rails.application).to receive(:assets){
            {
              "application.js": "asset string"
            }
          }
          allow_any_instance_of(Tempfile).to receive(:path){path}
        end

        it "should call transform_with_injections" do
          expect(subject).to receive(:transform_with_injections)
          subject.transform
        end

        it "should create a temp file, write to it and unlink it" do
          file = Object.new
          expect(subject).to receive(:injectable_scripts).twice{included_scripts}
          expect(subject).to receive(:find_asset_in_pipeline).once.with(included_scripts.first){""}
          expect(Tempfile).to receive(:new).with(['inject', '.js']){file}
          allow(file).to receive(:path){path}
          expect(file).to receive(:write)
          expect(file).to receive(:close)
          expect(file).to receive(:unlink)
          subject.transform
        end

        it "should call IO.popen with arguments" do
          expect(IO).to receive(:popen).with([
            GhostInThePost.phantomjs_path, 
            GhostInThePost::PhantomTransform::PHANTOMJS_SCRIPT, 
            html,
            GhostInThePost.remove_js_tags,
            path
          ])
          subject.transform
        end

        it "should return the result of IO.popen with arguments" do
          allow(IO).to receive(:popen) {"this is the end"}
          expect(subject.transform).to eq("this is the end")
        end

        it "should return the html if there was an error" do
          file = Object.new
          allow(Tempfile).to receive(:new).with(['inject', '.js']){file}
          allow(file).to receive(:path){path}
          allow(file).to receive(:write)
          allow(file).to receive(:close)
          allow(file).to receive(:unlink)
          allow(IO).to receive(:popen) {raise ArgumentError}
          expect(subject.transform).to eq(html)
        end

        it "should unlink file even if there was an error" do
          file = Object.new
          allow(Tempfile).to receive(:new).with(['inject', '.js']){file}
          allow(file).to receive(:path){path}
          allow(file).to receive(:write)
          allow(file).to receive(:close)
          allow(file).to receive(:unlink)
          allow(IO).to receive(:popen) {raise ArgumentError}
          subject.transform
        end                                               

      end

      context "without included_scripts" do
        let(:pt){PhantomTransform.new(html)}

        it "should call simple_transform" do
          expect(pt).to receive(:simple_transform)
          pt.transform
        end

        it "should call IO.popen with arguments" do
          expect(IO).to receive(:popen).with([
            GhostInThePost.phantomjs_path, 
            GhostInThePost::PhantomTransform::PHANTOMJS_SCRIPT, 
            html,
            GhostInThePost.remove_js_tags
          ])
          pt.transform
        end

        it "should return the result of IO.popen with arguments" do
          allow(IO).to receive(:popen) {"this is the end"}
          expect(pt.transform).to eq("this is the end")
        end

      end
    end

  end
end

