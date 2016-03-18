module GhostInThePost
  module JSLoaders
    module FileSystemLoader
      extend self

      def load(url)
        path = URI(url).path
        file_path = "public#{path}"
        File.read(file_path) if File.exist?(file_path)
      end
    end
  end
end
