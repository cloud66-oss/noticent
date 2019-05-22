module Noticent
  class Channel

    def initialize(recipients, payload, context)
      @recipients = recipients
      @payload = payload
      @context = context
    end

    protected

    attr_reader :payload
    attr_reader :recipients
    attr_reader :context

    def current_user
      raise Noticent::NoCurrentUser if @context[:current_user].nil?

      @context[:current_user]
    end

  end
end