module Noticent
  class Channel

    def initialize(recipients, payload)
      @recipients = recipients
      @payload = payload
    end

    protected

    attr_reader :payload
    attr_reader :recipients

  end
end