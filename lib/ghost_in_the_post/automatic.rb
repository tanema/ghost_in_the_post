module GhostInThePost
  module Automatic
    attr_accessor :included_scripts

    def include_script(*paths)
      @included_scripts ||= []
      @included_scripts += paths
    end

    def mail(*args, &block)
      super.tap do |email|
        email.extend GhostOnCommand
        email.extend GhostOnDelivery
        email.included_scripts = @included_scripts
      end
    end

  end
end
