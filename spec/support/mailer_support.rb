class BaseMailer
  def initialize(email = nil)
    @email = email
  end

  def mail(options = {})
    @email
  end

  def deliver!
  end

  def deliver
  end
end

class AutoMailer < BaseMailer
  include GhostInThePost::Automatic
end

class SomeMailer < BaseMailer
  include GhostInThePost::Mailer
end
