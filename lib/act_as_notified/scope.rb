# frozen_string_literal: true

module ActAsNotified
  class Scope

    attr_reader :name

    def initialize(config, name)
      @config = config
      @name = name
    end

    def alert(name, tags: [], &block)
      alerts = @config.instance_variable_get(:@alerts) || {}

      raise BadConfiguration, "alert '#{name}' already defined" if alerts.include? name

      alert = ActAsNotified::Alert.new(@config, name: name, scope: self, tags: tags)
      @config.hooks&.run(:pre_alert_registration, alert)
      alert.instance_eval(&block)
      @config.hooks&.run(:post_alert_registration, alert)

      alerts[name] = alert

      @config.instance_variable_set(:@alerts, alerts)
      alert
    end

  end
end