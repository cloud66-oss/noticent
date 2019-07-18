# frozen_string_literal: true

module Noticent
  class Dispatcher
    def initialize(config, alert_name, payload, configuration = {})
      @config = config
      @alert_name = alert_name
      @payload = payload
      @configuration = configuration

      validate!

      @entity_id = @payload.send("#{scope.name}_id")
    end

    def alert
      @config.alerts[@alert_name]
    end

    def scope
      alert.scope
    end

    def notifiers
      alert.notifiers
    end

    # returns all recipients of a certain notifier unfiltered regardless of "opt-in" and duplicates
    def recipients(notifier_name)
      raise Noticent::InvalidScope, "payload #{@payload.klass} doesn't have a #{notifier_name} method" unless @payload.respond_to? notifier_name

      @payload.send(notifier_name)
    end

    # only returns recipients that have opted-in for this channel
    def filter_recipients(recipients, channel)
      raise ArgumentError, "channel should be a string or symbol" unless channel.is_a?(String) || channel.is_a?(Symbol)
      raise ArgumentError, "recipients is nil" if recipients.nil?

      recipients.select { |recipient| @config.opt_in_provider.opted_in?(recipient_id: recipient.id, scope: scope.name, entity_id: @entity_id, alert_name: alert.name, channel_name: channel) }
    end

    def dispatch
      notifiers.values.each do |notifier|
        recs = recipients(notifier.recipient)
        notifier.applicable_channels.each do |channel|
          to_send = filter_recipients(recs, channel.name)

          if to_send.count == 0 && @config.skip_alert_with_no_subscribers
            Noticent.configuration.logger.info "Skipping alert #{alert.name} as they are no subscribers"
            return
          end

          channel_instance = channel.instance(@config, to_send, @payload, @configuration)
          begin
            raise Noticent::BadConfiguration, "channel #{channel.name} (#{channel.klass}) doesn't have a method called #{alert.name}" unless channel_instance.respond_to? alert.name

            channel_instance.send(alert.name)
          rescue StandardError => e
            # log and move on
            raise if @config.halt_on_error

            Noticent.configuration.logger.error e
          end
        end
      end
    end

    private

    def validate!
      raise Noticent::BadConfiguration, "no base_dir defined" if @config.base_dir.nil?
      raise Noticent::MissingConfiguration if @config.nil?
      raise Noticent::BadConfiguration if @config.alerts.nil?
      raise Noticent::InvalidAlert, "no alert #{@alert_name} found" if @config.alerts[@alert_name].nil?
      raise ::ArgumentError, "payload is nil" if @payload.nil?
      raise ::ArgumentError, "alert is not a symbol" unless @alert_name.is_a?(Symbol)
      raise Noticent::BadConfiguration, "payload (#{@payload.class}) doesn't belong to this scope (#{scope.name}) as it requires #{scope.payload_class}" unless !scope.payload_class.nil? && @payload.is_a?(scope.payload_class)
      raise Noticent::BadConfiguration, "payload doesn't have a #{scope.name}_id method" unless @payload.respond_to?("#{scope.name}_id")
    end
  end
end
