module GhostInThePost
  class PhantomTransform
    PHANTOMJS_SCRIPT = File.expand_path('../phantom/staticize.js', __FILE__)

    def initialize(html, included_scripts=[])
      @html = html
      @included_scripts = Array(included_scripts).compact
    end

    def transform
      injectable_scripts.any? ? transform_with_injections : simple_transform
    end

    private

    def command
      [
        GhostInThePost.phantomjs_path, 
        PHANTOMJS_SCRIPT, 
        @html,
        GhostInThePost.remove_js_tags
      ]
    end

    #there is scripts to inject so create a tmp file to put them all in
    def transform_with_injections
      #set output to just html so that if there is an error that is caught it will
      #at least return valid html
      output = @html
      begin
        #generate a tempfile with all the js that we need so that phantom can inject
        #easily and not have to max out a single command
        file = Tempfile.new(['inject', '.js'])
        injectable_scripts.map do |script|
          asset = find_asset_in_pipeline(script)
          file.write(asset.to_s) unless asset.nil?
        end.compact
        file.close #closing the file makes it accessible by phantom

        #generate the html with the javascript
        output = IO.popen(command + [file.path]){|io| io.read}

        file.unlink
      rescue => e
        #clean up the temp file
        file.unlink
      end
      output
    end

    #no scripts to inject so just run the command
    def simple_transform
      IO.popen(command){|io| io.read}
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
