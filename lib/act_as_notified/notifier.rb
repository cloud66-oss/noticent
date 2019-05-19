# frozen_string_literal: true

module ActAsNotified
  class Notifier

    def initialize(config, alert_name, payload)
      raise ActAsNotified::InvalidScope, 'no base_dir defined' if ActAsNotified.base_dir.nil?
      raise ActAsNotified::MissingConfiguration if config.nil?
      raise ActAsNotified::BadConfiguration if config.alerts.nil?
      raise ActAsNotified::InvalidScope if config.alerts[alert_name].nil?
      raise ::ArgumentError, 'payload is nil' if payload.nil?
      raise ::ArgumentError, 'alert is not a symbol' unless alert_name.is_a?(Symbol)
      raise ActAsNotified::BadConfiguration, 'payload should be ActAsNotified::Payload' unless payload.is_a? ActAsNotified::Payload


      @config = config
      @alert_name = alert_name
      @payload = payload
    end

    def alert
      @config.alerts[@alert_name]
    end

    def notifiers
      alert.notifiers
    end

    def filter_list(list)
      # TODO: no filtering for now
      list
    end

  end
end