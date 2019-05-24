module Noticent
  # this class helps with validation of any payload class in user's code.
  # using it is optional but recommended
  class Payload

    attr_reader :config
    attr_reader :scope

    def initialize(config, scope)
      @config = config
      @scope = scope
    end
  end
end