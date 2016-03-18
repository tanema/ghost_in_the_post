require 'nokogiri'

module GhostInThePost

  class AssetNotFoundError < StandardError; end
  
  class JsInline
    SCRIPT_ID = "ghost_in_the_post_script_container"
 
    STRATEGIES = [
      GhostInThePost::JSLoaders::CacheLoader,
      GhostInThePost::JSLoaders::FileSystemLoader,
      GhostInThePost::JSLoaders::AssetPipelineLoader,
      GhostInThePost::JSLoaders::NetworkLoader
    ]

    def initialize(html, included_scripts=[])
      self.html = html
      @included_scripts = Array(included_scripts).compact
    end

    def inline
      @dom.at_xpath('html/body').add_child("<script id='#{SCRIPT_ID}'>#{generate_flat_js}</script>")
    end

    def remove_all_script
      @dom.css('script').map(&:remove)
    end

    def remove_inlined
      @dom.css("##{SCRIPT_ID}").map(&:remove)
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
        asset = find_js(script)
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
 
    def find_js(url)
      STRATEGIES.each do |strategy|
        js = strategy.load(url)
        return js.force_encoding('UTF-8') if js
      end
    end

  end

end

