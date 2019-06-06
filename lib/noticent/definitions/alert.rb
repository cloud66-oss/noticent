# frozen_string_literal: true

module Noticent
  module Definitions
    class Alert
      attr_reader :name
      attr_reader :scope
      attr_reader :notifiers
      attr_reader :config
      attr_reader :products
      attr_reader :constructor_name

      def initialize(config, name:, scope:, constructor_name:)
        @config = config
        @name = name
        @scope = scope
        @constructor_name = constructor_name
        @products = Noticent::Definitions::ProductGroup.new(@config)
        @defaults = { any: Noticent::Definitions::Alert::DefaultValue.new(self, :any, config.default_value) }
      end

      def notify(recipient, template: '')
        notifiers = @notifiers || {}
        raise BadConfiguration, "a notify is already defined for '#{recipient}'" unless notifiers[recipient].nil?

        alert_notifier = Noticent::Definitions::Alert::Notifier.new(self, recipient, template: template)
        notifiers[recipient] = alert_notifier
        @notifiers = notifiers

        alert_notifier
      end

      def default_for(channel)
        raise ArgumentError, "no channel named '#{channel}' found" if @config.channels[channel].nil?

        @defaults[channel].nil? ? @defaults[:any].value : @defaults[channel].value
      end

      def default_value
        @defaults[:any].value
      end

      def default(value, &block)
        defaults = @defaults

        if block_given?
          default = Noticent::Definitions::Alert::DefaultValue.new(self, :any, value)
          default.instance_eval(&block)

          defaults[default.channel] = default
        else
          defaults[:any].value = value
        end

        @defaults = defaults

        default
      end

      def applies
        @products
      end

      def validate!
        channels = @config.alert_channels(@name)
        raise BadConfiguration, "no notifiers are assigned to alert '#{@name}'" if @notifiers.nil? || @notifiers.empty?

        channels.each do |channel|
          raise BadConfiguration, "channel #{channel.name} (#{channel.klass}) has no method called #{@name}" unless channel.klass.method_defined? @name
        end

        # if a payload class is available, we can make sure it has a constructor with the name of the event
        raise Noticent::BadConfiguration, "payload #{@scope.payload_class} doesn't have a class method called #{name}" if @scope.check_constructor && !@scope.payload_class.respond_to?(@constructor_name)
      end

      # holds a list of recipient + channel
      class Notifier
        attr_reader :recipient
        attr_reader :channel_group
        attr_reader :template

        def initialize(alert, recipient, template: '')
          @recipient = recipient
          @alert = alert
          @config = alert.config
          @template = template
          @channel_group = :default
        end

        def on(channel_group)
          # validate the group name
          raise ArgumentError, "no channel group found named '#{channel_group}'" if @config.channels_by_group(channel_group).empty?

          @channel_group = channel_group
        end
      end

      class DefaultValue
        attr_reader :channel
        attr_accessor :value

        def initialize(alert, channel, value)
          @alert = alert
          @channel = channel
          @value = value
        end

        def on(channel)
          raise BadConfiguration, "no channel named '#{channel}'" if @alert.config.channels[channel].nil?

          @channel = channel

          self
        end

      end
    end
  end
end
