# frozen_string_literal: true

module Noticent
  module Definitions
    class Channel

      attr_reader :name
      attr_reader :group

      def initialize(config, name, group: :default)
        @name = name
        @group = group
        @config = config
        @suggested_class_name = Noticent.base_module_name + '::' + name.to_s.camelize
      end

      def configure(klass)
        @klass = klass
      end

      def validate!
        @suggested_class_name.camelize.constantize
        raise BadConfiguration, "channel '#{@name}' (#{klass}) should inherit from ::Noticent::Channel" unless klass <= ::Noticent::Channel
      rescue NameError
        raise Noticent::BadConfiguration, "no class found for #{@suggested_class_name}"
      end

      def klass
        @klass ||= @suggested_class_name.camelize.constantize
      end

      def instance(recipients, payload)
        klass.new(recipients, payload)
      rescue ArgumentError
        raise Noticent::BadConfiguration, "channel #{klass} initializer arguments are mismatching."
      end
    end
  end
end