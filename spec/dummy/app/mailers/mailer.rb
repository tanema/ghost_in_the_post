class Mailer < ActionMailer::Base
  include GhostInThePost::Mailer

  default from: 'john@example.com'

  def normal_email
    mail(to: 'example@example.org', subject: "Notification for you") do |format|
      format.html
      format.text
    end
  end

end
