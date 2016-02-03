module GhostInThePost
  module GhostOnDelivery
    def deliver
      ghost
      super
    end
    def deliver!
      ghost
      super
    end
  end
end
