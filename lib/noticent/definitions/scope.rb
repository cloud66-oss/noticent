# frozen_string_literal: true

module Noticent
  module Definitions
    class Scope
      attr_reader :name
      attr_reader :payload_class

      def initialize(config, name, payload_class: nil)
        @config = config
        @name = name
        suggeste_name = config.base_module_name + "::#{name.capitalize}Payload"
        @payload_class = payload_class.nil? ? suggeste_name.constantize : payload_class
      rescue NameError
        raise BadConfiguration, "scope #{suggeste_name} class not found"
      end

      def alert(name, &block)
        alerts = @config.instance_variable_get(:@alerts) || {}

        raise BadConfiguration, "alert '#{name}' already defined" if alerts.include? name

        alert = Noticent::Definitions::Alert.new(@config, name: name, scope: self)
        @config.hooks&.run(:pre_alert_registration, alert)
        alert.instance_eval(&block) if block_given?
        @config.hooks&.run(:post_alert_registration, alert)

        alerts[name] = alert

        @config.instance_variable_set(:@alerts, alerts)
        alert
      end

      def validate!
        # klass is valid already as it's used in the initializer
        # does it have the right attributes?
        # fetch all alerts for this scope
        return if @payload_class.nil?

        @config.alerts_by_scope(name).each do |alert|
          next if alert.notifiers.nil?

          alert.notifiers.keys.each do |recipient|
            raise BadConfiguration, "payload class #{@payload_class} doesn't have a method or attribute called #{recipient}" unless @payload_class.method_defined? recipient
          end
        end

        raise BadConfiguration, "payload class #{@payload_class} does have an attribute or method called #{name}_id" if !@payload_class.nil? && !@payload_class.method_defined?("#{name}_id")
      end
    end
  end
end
