# frozen_string_literal: true

module Noticent
  module Definitions
    class Scope
      attr_reader :name
      attr_reader :klass
      attr_reader :payload_class

      def initialize(config, name, payload_class: nil, klass: nil, constructor: nil)
        @config = config
        @name = name
        @klass = klass.nil? ? (@config.base_module_name + '::' + name.to_s.camelize).camelize.constantize : klass
        @constructor = constructor.nil? ? -> { @klass.new } : constructor
        @payload_class = payload_class
      rescue NameError
        raise BadConfiguration, "scope #{name} class not found"
      end

      def alert(name, tags: [], &block)
        alerts = @config.instance_variable_get(:@alerts) || {}

        raise BadConfiguration, "alert '#{name}' already defined" if alerts.include? name

        alert = Noticent::Definitions::Alert.new(@config, name: name, scope: self, tags: tags)
        @config.hooks&.run(:pre_alert_registration, alert)
        alert.instance_eval(&block) if block_given?
        @config.hooks&.run(:post_alert_registration, alert)

        alerts[name] = alert

        @config.instance_variable_set(:@alerts, alerts)
        alert
      end

      def instance
        @constructor.call
      rescue ArgumentError
        raise BadConfiguration, "scope #{name} cannot be created because of an ArgumentError. Are you using a class with a custom initializer without using the constructor argument?"
      end

      def validate!
        # klass is valid already as it's used in the initializer
        # does it have the right attributes?
        # fetch all alerts for this scope
        @config.alerts_by_scope(name).each do |alert|
          next if alert.notifiers.nil?

          alert.notifiers.keys.each do |recipient|
            raise BadConfiguration, "scope #{name} doesn't have a method or attribute called #{recipient}" unless @config.scopes[name].instance.respond_to? recipient
            raise BadConfiguration, "scope #{name} doesn't have an id attribute" unless @config.scopes[name].instance.respond_to? :id
          end
        end

        raise BadConfiguration, "payload class #{@payload_class} does have an attribute or method called #{name}" if !@payload_class.nil? && !@payload_class.method_defined?(name)
      end
    end
  end
end
