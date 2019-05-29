# frozen_string_literal: true

module Noticent
  module Definitions
    class Product
      attr_reader :name

      def initialize(config, name)
        raise BadConfiguration, 'product name should be a symbol' unless name.is_a? Symbol

        @config = config
        @name = name
      end
    end
  end
end
