# frozen_string_literal: true

module Noticent
  module Definitions
    class Alert
      attr_reader :name
      attr_reader :scope
      attr_reader :notifiers
      attr_reader :config
      attr_reader :products

      def initialize(config, name:, scope:)
        @config = config
        @name = name
        @scope = scope
        @products = Noticent::Definitions::ProductGroup.new(@config)
      end

      def notify(recipient, template: '')
        notifiers = @notifiers || {}
        raise BadConfiguration, "a notify is already defined for '#{recipient}'" unless notifiers[recipient].nil?

        alert_notifier = Noticent::Definitions::Alert::Notifier.new(self, recipient, template: template)
        notifiers[recipient] = alert_notifier
        @notifiers = notifiers

        alert_notifier
      end

      def applies
        @products
      end

      def validate!
        channels = @config.alert_channels(@name)
        channels.each do |channel|
          raise BadConfiguration, "channel #{channel.name} (#{channel.klass}) has no method called #{@name}" unless channel.klass.method_defined? @name
        end
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
    end
  end
end
