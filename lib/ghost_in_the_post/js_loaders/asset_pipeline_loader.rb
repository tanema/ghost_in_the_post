module GhostInThePost
  module JSLoaders
    module AssetPipelineLoader
      extend self

      def load(url)
        if asset_pipeline_present?
          file = file_name(url)
          asset = ::Rails.application.assets.find_asset(file)
          asset.to_s if asset
        end
      end

      def asset_pipeline_present?
        defined?(::Rails) &&
          ::Rails.application.respond_to?(:assets) &&
          ::Rails.application.assets
      end
 
      DIGEST_PATTERN = /
        -                # Digest comes after a dash
        (?:
         [a-z0-9]{32} |  # Old style is 32 character hash
         [a-z0-9]{64}    # New style is 64 characters
        )
        \.               # Dot for the file extension
      /x.freeze

      def file_name(url)
        URI(url).path
          .sub("#{::Rails.configuration.assets.prefix}/", '')
          .gsub(DIGEST_PATTERN, '.')
      end
    end
  end
end
