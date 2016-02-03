module GhostInThePost
  module GhostOnCommand
    attr_accessor :included_scripts

    def ghost
      MailGhost.new(self, included_scripts).execute
    end
  end
end

