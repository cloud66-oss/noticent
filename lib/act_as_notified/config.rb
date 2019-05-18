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

  def self.notify(alert, payload)
    raise ActAsNotified::MissingConfiguration if @config.nil?
    raise ::ArgumentError, 'payload is nil' if payload.nil?
    raise ::ArgumentError, 'alert is not a symbol' unless alert.is_a?(Symbol)
    raise ActAsNotified::BadConfiguration, 'payload should be ActAsNotified::Payload' unless payload.is_a? ActAsNotified::Payload
    raise ActAsNotified::BadConfiguration if @config.alerts.nil?
    raise ActAsNotified::InvalidScope if @config.alerts[alert].nil?
    raise ActAsNotified::InvalidScope, 'no base_dir defined' if @@base_dir.nil?

    scope = @config.alerts[alert].scope
    payload_class_file = File.expand_path(File.join(@@base_dir, 'payloads', alert.to_s + '_payload.rb'))
    raise ActAsNotified::InvalidScope, "payload file for '#{scope}' not found in #{payload_class_file}" unless File.exist?(payload_class_file)
  end

  class Config
    attr_reader :hooks
    attr_reader :channels
    attr_reader :scopes
    attr_reader :alerts

    class Builder

      def initialize(&block)
        @config = ActAsNotified::Config.new
        instance_eval(&block) if block_given?
      end

      def build
        @config
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

        channel = ActAsNotified::Channel.new(@config, name, group: group)
        hooks.run(:pre_channel_registration, channel)
        channel.instance_eval(&block)
        hooks.run(:post_channel_registration, channel)

        channels[name] = channel

        @config.instance_variable_set(:@channels, channels)
        channel
      end

      def scope(name, &block)
        scopes = @config.instance_variable_get(:@scopes) || {}

        raise BadConfiguration, "scope '#{name}' already defined" if scopes.include? name

        scope = ActAsNotified::Scope.new(@config, name)
        scope.instance_eval(&block)

        scopes[name] = scope

        @config.instance_variable_set(:@scopes, scopes)
        scope
      end

    end

  end
end
