require "spec_helper"

describe GhostInThePost do

  before :each do
    #reload so that variables are set to initials values
    quiet_load 'ghost_in_the_post.rb'
    allow(File).to receive(:exist?){|path|
      path == "test_path"
    }
  end
  
  describe "#create=" do
    it "should complain if you add unknown keys" do
      expect do
        GhostInThePost.config = {bad_key: "blah"} 
      end.to raise_error(ArgumentError)
    end
    it "should set phantomjs_path" do
      GhostInThePost.config = {phantomjs_path: "test_path"}
      expect(GhostInThePost.phantomjs_path).to eq("test_path")
    end
    it "should raise ArgumentError if not path was set for phantom" do
      expect do
        GhostInThePost.config = {} 
      end.to raise_error(ArgumentError)
    end
    it "should raise ArgumentError if path was set for phantom but it is not at that path" do
      expect do
        GhostInThePost.config = {phantomjs_path: "nope"} 
      end.to raise_error(ArgumentError)
    end
    it "should set includes" do
      GhostInThePost.config = {phantomjs_path: "test_path", includes: ["test"]}
      expect(GhostInThePost.includes).to eq(["test"])
    end
    it "should force includes to an array" do
      GhostInThePost.config = {phantomjs_path: "test_path", includes: "test"}
      expect(GhostInThePost.includes).to eq(["test"])
    end
    it "should default includes to an empty array" do
      GhostInThePost.config = {phantomjs_path: "test_path"}
      expect(GhostInThePost.includes).to eq([])
    end
    it "should set remove_js_tags" do
      GhostInThePost.config = {phantomjs_path: "test_path", remove_js_tags: false}
      expect(GhostInThePost.remove_js_tags).to eq(false)
    end
    it "should default remove_js_tags to true" do
      GhostInThePost.config = {phantomjs_path: "test_path"}
      expect(GhostInThePost.remove_js_tags).to eq(true)
    end
  end

  describe "#phantomjs_path" do
    it "should return phantomjs_path" do
      GhostInThePost.config = {phantomjs_path: "test_path"}
      expect(GhostInThePost.phantomjs_path).to eq("test_path")
    end
    it "should raise and ArgumentError if the path is not set" do
      expect do
        GhostInThePost.phantomjs_path
      end.to raise_error(ArgumentError)
    end
  end

end

