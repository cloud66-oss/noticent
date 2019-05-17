# freeze_string_literal: true

module ActAsNotified
  class Channel

    attr_reader :name
    attr_reader :group
    attr_reader :configurer
    attr_reader :config_options

    def initialize(name, group: :default)
      @name = name
      @group = group
    end

    def configure(klass)
      @configurer = klass
      @config_options = ConfigOptions.new
    end

    class ConfigOptions
      attr_reader :options

      def using(options = {})
        @options = options
      end

    end


  end
end