# frozen_string_literal: true

module Noticent
  module Definitions
    class Channel

      attr_reader :name
      attr_reader :group
      attr_reader :config_options

      def initialize(config, name, group: :default)
        @name = name
        @group = group
        @config = config
        @suggested_class_name = Noticent.base_module_name + '::' + name.to_s.camelize
      end

      def configure(klass)
        @klass = klass
        @config_options = ConfigOptions.new
      end

      def validate!
        if @config_options.nil?
          begin
            @suggested_class_name.camelize.constantize
          rescue NameError
            raise Noticent::BadConfiguration, "no class found for #{@suggested_class_name}"
          end
        end
        raise BadConfiguration, "channel '#{@name}' (#{klass}) should inherit from ::Noticent::Channel" unless klass <= ::Noticent::Channel
      end

      def klass
        if @config_options.nil?
          @klass ||= @suggested_class_name.camelize.constantize
        else
          @klass
        end
      end

      def instance
        if !@config_options.nil? && !@config_options.options.nil?
          klass.new(@config_options)
        else
          klass.new
        end
      rescue ArgumentError
        raise Noticent::BadConfiguration, "channel #{klass} initializer arguments are mismatching. Are you using `configure` and `using` properly?"
      end

      class ConfigOptions
        attr_reader :options

        def using(options = {})
          @options = options
        end

      end

    end
  end
end