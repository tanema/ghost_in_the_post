module GhostInThePost
  class MailGhost
    attr_reader :email, :included_scripts

    def initialize(email, included_scripts)
      @email = email
      @included_scripts = Array(included_scripts).compact
    end

    def execute
      improve_body if email.content_type =~ /^text\/html/
      improve_html_part(email.html_part) if email.html_part
      email
    end

    private

    def improve_body
      email.body = ghost_html(email.body.decoded)
    end

    def improve_html_part(html_part)
      html_part.body = ghost_html(html_part.body.decoded)
    end

    def ghost_html(old_html)
      PhantomTransform.new(old_html, included_scripts).transform
    end
  end
end
