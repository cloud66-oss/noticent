# frozen_string_literal: true

module Noticent
  class Error < StandardError; end
  class BadConfiguration < Error; end
  class InvalidPayload < Error; end
  class InvalidScope < Error; end
  class InvalidAlert < Error; end
  class NoCurrentUser < Error; end

  class MissingConfiguration < Error
    def initialize
      super('Configuration for noticent missing. Do you have noticent initializer?')
    end
  end

end