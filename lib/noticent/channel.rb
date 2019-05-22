# freeze_string_literal: true

module Noticent
  class Channel

    attr_reader :name
    attr_reader :group
    attr_reader :klass
    attr_reader :config_options

    def initialize(config, name, group: :default)
      @name = name
      @group = group
      @config = config
      # this might be overwritten with configure but acts as a default fallback
      @klass = (Noticent.base_module_name + '::' + name.to_s.camelize).camelize.constantize
    end

    def configure(klass)
      @klass = klass
      @config_options = ConfigOptions.new
    end

    def instance
      if !@config_options.nil? && !@config_options.options.nil?
        klass.new(@config_options)
      else
        klass.new
      end
    rescue ArgumentError
      raise Noticent::BadConfiguration, "channel #{@klass} initializer arguments are mismatching. Are you using `configure` and `using` properly?"
    end

    class ConfigOptions
      attr_reader :options

      def using(options = {})
        @options = options
      end

    end


  end
end