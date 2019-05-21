# frozen_string_literal: true

module ActAsNotified
  class Dispatcher
	
    def initialize(config, alert_name, payload)
      @config = config
      @alert_name = alert_name
      @payload = payload

      validate!
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

	# returns all recepients of a certain notifier unfiltered regardless of "opt-in" and duplicates
	def recipients(notifier)
      scope_object = scope.instance
      raise ActAsNotified::InvalidScope, "scope '#{@klass}' doesn't have a #{notifier} method" unless scope_object.respond_to? notifier

      scope_object.send(notifier, @payload)
    end

  def filter_recipients(recipients, channel)
    # recipient is recepients 
    return recipients.select { |recipient| ActAsNotified.opt_in_provider.opted_in?(scope: scope, entity_id: recipient.id, alert_name: alert, channel_name: channel) }
  end

    private

    def validate!
      raise ActAsNotified::InvalidScope, 'no base_dir defined' if ActAsNotified.base_dir.nil?
      raise ActAsNotified::MissingConfiguration if @config.nil?
      raise ActAsNotified::BadConfiguration if @config.alerts.nil?
      raise ActAsNotified::InvalidScope if @config.alerts[@alert_name].nil?
      raise ::ArgumentError, 'payload is nil' if @payload.nil?
      raise ::ArgumentError, 'alert is not a symbol' unless @alert_name.is_a?(Symbol)
	  raise ActAsNotified::BadConfiguration, 'payload should be ActAsNotified::Payload' unless @payload.is_a? ActAsNotified::Payload
    end

  end
end