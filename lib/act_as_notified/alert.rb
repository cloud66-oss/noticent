# frozen_string_literal: true

module ActAsNotified
  class Alert

    attr_reader :name
    attr_reader :scope
    attr_reader :notifiers
    attr_reader :tags
    attr_reader :config

    def initialize(config, name:, scope:, tags: [])
      @config = config
      @name = name
      @scope = scope
      @tags = tags
    end

    def notify(recipient, template: '')
      notifiers = @notifiers || {}
      raise BadConfiguration, "a notify is already defined for '#{recipient}'" unless notifiers[recipient].nil?

      alert_notifier = ActAsNotified::Alert::Notifier.new(self, recipient, template: template)
      notifiers[recipient] = alert_notifier
      @notifiers = notifiers

      alert_notifier
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