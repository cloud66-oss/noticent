# frozen_string_literal: true

module Noticent
  module Definitions
    class ProductGroup

      attr_reader :products

      def initialize(config)
        @config = config
        @products = {}
      end

      def to(name)
        raise BadConfiguration, 'product name should be a symbol' unless name.is_a? Symbol
        raise BadConfiguration, "product #{name} is already in the list" if @products[name]
        raise BadConfiguration, "product #{name} is not defined. Use products to define it first" unless @config.products[name]

        @products[name] = @config.products[name]
      end

      def not_to(name)
        raise BadConfiguration, 'product name should be a symbol' unless name.is_a? Symbol
        raise BadConfiguration, "product #{name} is not defined. Use products to define it first" unless @config.products[name]

        # include all products, except the one named
        @config.products.each { |k, v| @products[k] = v unless k == name }
      end

      def count
        @products.count
      end

      def keys
        @products.keys
      end

      def values
        @products.values
      end

    end
  end
end
