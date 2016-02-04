module GhostInThePost
  
  class GhostJSError < StandardError; end

  class PhantomTransform
    PHANTOMJS_SCRIPT = File.expand_path('../phantom/staticize.js', __FILE__)
    ERROR_TAG = "[GHOSTINTHEPOST-STATICIZE-ERROR]"

    def initialize(html, timeout=nil, wait_event=nil, included_scripts=nil)
      @inliner = JsInline.new(html, included_scripts)
      @timeout = timeout || GhostInThePost.timeout
      @wait_event = wait_event || GhostInThePost.wait_event
    end

    def transform
      @inliner.inline
      p @inliner.html if GhostInThePost.debug
      @inliner.html = checkError(IO.popen(command){|io| io.read})
      @inliner.remove_all_script if GhostInThePost.remove_js_tags
      @inliner.html
    end

    private

    def command
      [
        GhostInThePost.phantomjs_path, 
        PHANTOMJS_SCRIPT, 
        @inliner.html,
        @timeout,
        @wait_event,
      ].map(&:to_s)
    end

    def checkError output
      raise GhostJSError.new(output.gsub(ERROR_TAG, "")) if output.start_with?(ERROR_TAG)
      output
    end

  end
end
