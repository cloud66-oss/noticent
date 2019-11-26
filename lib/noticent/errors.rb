# frozen_string_literal: true

module Noticent
  class Error < StandardError; end
  class BadConfiguration < Error; end
  class InvalidPayload < Error; end
  class InvalidScope < Error; end
  class InvalidAlert < Error; end
  class NoCurrentUser < Error; end
  class ViewNotFound < Error; end

  class MissingConfiguration < Error
    def initialize
      super('Configuration for noticent missing. Do you have noticent initializer?')
    end
  end

  class MultipleError < Error
    # original errors and backtraces are available via the "errors" accessor
    attr_reader :errors
    # should be initialized with a collection of ::Noticent::Error
    def initialize(*args)
      @errors = args.flatten
      mapped_errors = []
      @errors.each_with_index{|error, idx|mapped_errors << "Error#{idx+1}: #{error.message}"}
      error_message = "Multiple errors have occurred! #{mapped_errors.join('. ')}"
      super(error_message)
    end
  end
end
