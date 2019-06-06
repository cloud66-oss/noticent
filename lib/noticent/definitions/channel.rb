# frozen_string_literal: true

module Noticent
  module Definitions
    class Channel
      attr_reader :name
      attr_reader :group
      attr_reader :klass
      attr_reader :options

      def initialize(config, name, group: :default, klass: nil)
        raise BadConfiguration, 'name should be a symbol' unless name.is_a? Symbol
        raise BadConfiguration, '\'any\' is a reserved channel name' if name == :any

        @name = name
        @group = group
        @config = config

        sub_module = @config.use_sub_modules ? '::Channels::' : '::'
        suggested_class_name = @config.base_module_name + sub_module + name.to_s.camelize

        @klass = klass.nil? ? suggested_class_name.camelize.constantize : klass
      rescue NameError
        raise Noticent::BadConfiguration, "no class found for #{suggested_class_name}"
      end

      def using(options = {})
        @options = options
      end

      def instance(config, recipients, payload, context)
        inst = @klass.new(config, recipients, payload, context)
        return inst if @options.nil? || @options.empty?

        @options.each do |k, v|
          inst.send("#{k}=", v)
        rescue NoMethodError
          raise Noticent::BadConfiguration, "no method #{k}= found on #{@klass} as it is defined with the `using` clause"
        end

        inst
      rescue ArgumentError
        raise Noticent::BadConfiguration, "channel #{@klass} initializer arguments are mismatching."
      end
    end
  end
end
