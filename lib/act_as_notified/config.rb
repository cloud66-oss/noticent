# frozen_string_literal: true

module ActAsNotified
  def self.configure(&block)
    raise ActAsNotified::Error, 'no block given' unless block_given?

    @config = ActAsNotified::Config::Builder.new(&block).build
    @config
  end

  def self.configuration
    @config || (raise ActAsNotified::MissingConfiguration)
  end

  class Config
    attr_reader :payloads
    attr_reader :scopes
    attr_reader :recipients
    attr_reader :aliases
    attr_reader :hooks
    attr_reader :channels
    attr_reader :alerts

    class Builder

      def initialize(&block)
        @config = ActAsNotified::Config.new
        instance_eval(&block) if block_given?
      end

      def build
        @config.validate
        @config
      end


      # registers procs that extract models from an event payload
      def for_payloads(&block)
        raise BadConfiguration, 'payload have already been defined' unless @payloads.nil?

        @payloads = ActAsNotified::Payloads.new(@config)
        @payloads.instance_eval(&block)

        @config.instance_variable_set(:@payloads, @payloads)
        @payloads
      end

      def for_scopes(&block)
        raise BadConfiguration, 'scopes have already been defined' unless @scopes.nil?

        @scopes = ActAsNotified::Scopes.new(@config)
        @scopes.instance_eval(&block)

        @config.instance_variable_set(:@scopes, @scopes)
        @scopes
      end

      def recipients(type, &block)
        recipients = ActAsNotified::Recipients.new(@config)
        recipients.instance_eval(&block)

        config_recipients = @config.instance_variable_get(:@recipients) || {}
        config_recipients[type] = recipients

        @config.instance_variable_set(:@recipients, config_recipients)
        recipients
      end

      def scope_alias(map)
        @config.instance_variable_set(:@aliases, map)
      end

      def hooks
        if @config.hooks.nil?
          @config.instance_variable_set(:@hooks, ActAsNotified::Hooks.new)
        else
          @config.hooks
        end
      end

      def channel(name, group: :default, &block)
        channels = @config.instance_variable_get(:@channels) || {}

        raise BadConfiguration, "channel '#{name}' already defined" if channels.include? name

        channel = ActAsNotified::Channel.new(ActAsNotified::Config.new, name, group: group)
        hooks.run(:pre_channel_registration, channel)
        channel.instance_eval(&block)
        hooks.run(:post_channel_registration, channel)

        channels[name] = channel

        @config.instance_variable_set(:@channels, channels)
        channel
      end

      def alert(name, scope: [:all], &block)
        alerts = @config.instance_variable_get(:@alerts) || {}

        raise BadConfiguration, "alert '#{name}' already defined" if alerts.include? name

        alert = ActAsNotified::Alert.new(ActAsNotified::Config.new, name, scope: scope)
        hooks.run(:pre_alert_registration, alert)
        alert.instance_eval(&block)
        hooks.run(:post_alert_registration, alert)

        alerts[name] = alert

        @config.instance_variable_set(:@alerts, alerts)
        alert
      end

    end

    def validate
      # TODO: Validate
    end

  end
end
