module GhostInThePost
  class PhantomTransform
    PHANTOMJS_SCRIPT = File.expand_path('../phantom/staticize.js', __FILE__)

    def initialize(html, timeout=nil, wait_event=nil, included_scripts=[])
      @html = html
      @timeout = timeout || GhostInThePost.timeout
      @wait_event = wait_event || GhostInThePost.wait_event
      @included_scripts = Array(included_scripts).compact
    end

    def transform
      output = @html
      begin
        htmlfile = html_file()
        jsfile = js_file()
        output = IO.popen(command(htmlfile, jsfile)){|io| io.read}
      ensure
        htmlfile.unlink unless htmlfile.nil?
        jsfile.unlink unless jsfile.nil?
      end
      output
    end

    private

    def command(htmlfile, jsfile)
      [
        GhostInThePost.phantomjs_path, 
        PHANTOMJS_SCRIPT, 
        htmlfile.path,
        GhostInThePost.remove_js_tags,
        jsfile.path,
        @timeout,
        @wait_event,
      ].map(&:to_s)
    end

    #generate a tempfile with all the html that we need so that phantom can inject
    #easily and not have to max out a single command
    def html_file
      file = Tempfile.new(['inject', '.html'])
      file.write(@html)
      file.close #closing the file makes it accessible by phantom
      file
    end

    #generate a tempfile with all the js that we need so that phantom can inject
    #easily and not have to max out a single command
    def js_file
      jsfile = Tempfile.new(['inject', '.js'])
      injectable_scripts.map do |script|
        asset = find_asset_in_pipeline(script)
        jsfile.write(asset.to_s) unless asset.nil?
      end.compact
      jsfile.close #closing the file makes it accessible by phantom
      jsfile
    end

    def injectable_scripts
      @injectable_scripts ||= (GhostInThePost.includes + @included_scripts)
    end
 
    def find_asset_in_pipeline(name)
      normalized_name = normalize_asset_name(name)
      Rails.application.assets[normalized_name] || Rails.application.assets[remove_asset_digest(normalized_name)]
    end

    def normalize_asset_name(href)
      remove_asset_prefix(href.split('?').first)
    end

    DIGEST_PATTERN = /
      -                # Digest comes after a dash
      (?:
       [a-z0-9]{32} |  # Old style is 32 character hash
       [a-z0-9]{64}    # New style is 64 characters
      )
      \.               # Dot for the file extension
    /x.freeze

    def remove_asset_digest(path)
      path.gsub(DIGEST_PATTERN, '.')
    end

    def remove_asset_prefix(path)
      path.sub(Regexp.new("^#{Regexp.quote(asset_prefix)}/?"), "")
    end

    def asset_prefix
      ::Rails.application.try(:config).try(:assets).try(:prefix) || "/assets"
    end

  end
end
