module GhostInThePost
  module Automatic
    attr_accessor :included_scripts, :ghost_timeout, :ghost_wait_event

    def include_script(*paths)
      @included_scripts ||= []
      @included_scripts += paths
    end

    def mail(*args, &block)
      super.tap do |email|
        email.extend GhostOnCommand
        email.extend GhostOnDelivery
        email.included_scripts = @included_scripts
        email.ghost_timeout = @ghost_timeout
        email.ghost_wait_event = @ghost_wait_event
      end
    end

  end
end
