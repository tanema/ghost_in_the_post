class AutoMailer < ActionMailer::Base
  include GhostInThePost::Automatic

  default from: 'john@example.com'

  def normal_email
    set_ghost_timeout 5000
    mail(to: 'example@example.org', subject: "Notification for you") do |format|
      format.html { render :normal_email }
      format.text { render :normal_email }
    end
  end

end
