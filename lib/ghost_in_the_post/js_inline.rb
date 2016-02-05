require 'nokogiri'

module GhostInThePost

  class AssetNotFoundError < StandardError; end
  
  class JsInline

    def initialize(html, included_scripts=[])
      self.html = html
      @included_scripts = Array(included_scripts).compact
    end

    def inline
      @dom.at_xpath('html/body').add_child("<script>#{generate_flat_js}</script>")
    end

    def remove_all_script
      @dom.css('script').map(&:remove)
    end

    def html=(html)
      @dom = Nokogiri::HTML.parse(html, nil, Encoding::UTF_8.to_s)
    end

    def html
      @dom.to_html
    end

    private

    def generate_flat_js
      injectable_scripts.map do |script|
        asset = find_asset_in_pipeline(script)
        if GhostInThePost.raise_asset_errors and asset.nil?
          raise AssetNotFoundError.new("cannot find asset #{normalize_asset_name(script)}")
        end
        asset.to_s unless asset.nil?
      end.compact.join("\n")
    end

    def injectable_scripts
      doc_scripts = @dom.css('script').map do |script_node|
        src = script_node['src']
        script_node.remove unless src.nil?
        src
      end.compact
      doc_scripts + GhostInThePost.includes + @included_scripts
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

