# frozen_string_literal: true

module ActAsNotified
  class Error < StandardError; end
  class BadConfiguration < Error; end
  class InvalidPayload < Error; end
  class InvalidScope < Error; end
  class InvalidAlert < Error; end

  class MissingConfiguration < Error
    def initialize
      super('Configuration for act_as_notified missing. Do you have act_as_notified initializer?')
    end
  end

end