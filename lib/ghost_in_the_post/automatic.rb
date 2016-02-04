module GhostInThePost
  module Automatic
    include Mailer
    def mail(*args, &block)
      super.tap do |email|
        email.extend GhostOnDelivery
      end
    end
  end
end
