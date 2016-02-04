module GhostInThePost
  module Mailer

    def include_script(*paths)
      @included_scripts ||= []
      @included_scripts += paths
    end

    def set_ghost_timeout timeout
      @ghost_timeout = timeout
    end

    def set_ghost_wait_event wait_event
      @ghost_wait_event = wait_event
    end

    def mail(*args, &block)
      super.tap do |email|
        email.extend GhostOnCommand
        email.included_scripts = @included_scripts
        email.ghost_timeout = @ghost_timeout
        email.ghost_wait_event = @ghost_wait_event
      end
    end
  end
end
