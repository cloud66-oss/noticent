# freeze_string_literal: true

module ActAsNotified
  class Channel

    attr_reader :name
    attr_reader :group
    attr_reader :configurer
    attr_reader :config_options
    attr_reader :klass

    def initialize(config, name, group: :default, klass: nil)
      @name = name
      @group = group
      @config = config
      @klass = klass.nil? ? (ActAsNotified.base_module_name + '::' + name.to_s.camelize).camelize.constantize : klass
    end

    def configure(klass)
      @configurer = klass
      @config_options = ConfigOptions.new
    end

    def instance
      if klass.method(:initialize).arity.positive?
        klass.new(@config_options)
      else
        klass.new
      end

    end

    class ConfigOptions
      attr_reader :options

      def using(options = {})
        @options = options
      end

    end


  end
end