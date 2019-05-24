# frozen_string_literal: true

module Noticent
  module Definitions
    class Channel
      attr_reader :name
      attr_reader :group
      attr_reader :klass

      def initialize(config, name, group: :default, klass: nil)
        @name = name
        @group = group
        @config = config

        suggested_class_name = @config.base_module_name + '::' + name.to_s.camelize
        @klass = klass.nil? ? suggested_class_name.camelize.constantize : klass
      rescue NameError
        raise Noticent::BadConfiguration, "no class found for #{suggested_class_name}"
      end

      def instance(config, recipients, payload, context)
        @klass.new(config, recipients, payload, context)
      rescue ArgumentError
        raise Noticent::BadConfiguration, "channel #{@klass} initializer arguments are mismatching."
      end
    end
  end
end
