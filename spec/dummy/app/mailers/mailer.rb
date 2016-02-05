class Mailer < ActionMailer::Base
  include GhostInThePost::Mailer
  default from: 'john@example.com'

  def normal
    mail(to: 'example@example.org', subject: "Notification for you")
  end

  def multi
    mail(to: 'example@example.org', subject: "Notification for you") do |format|
      format.html
      format.text
    end
  end

  def timeout
    set_ghost_timeout 60000
    mail(to: 'example@example.org', subject: "Notification for you")
  end

end
