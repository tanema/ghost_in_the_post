module GhostInThePost
  module GhostOnCommand
    attr_accessor :included_scripts, :ghost_timeout, :ghost_wait_event

    def ghost
      MailGhost.new(self, ghost_timeout, ghost_wait_event, included_scripts).execute
    end
  end
end

