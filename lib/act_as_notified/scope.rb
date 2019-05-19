# frozen_string_literal: true

module ActAsNotified
  class Scope

    attr_reader :name
    attr_reader :class_name

    def initialize(config, name, class_name: '')
      @config = config
      @name = name
      @class_name = class_name == '' ? ActAsNotified.base_module_name + "::" + name.to_s.camelize : class_name
      klass_file = File.join(ActAsNotified.base_dir, "scopes", "#{@name.to_s}.rb")
      raise ActAsNotified::BadConfiguration, "scope #{name} is missing from #{klass_file}" unless File.exist?(klass_file)
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