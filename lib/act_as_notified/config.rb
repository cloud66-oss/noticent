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

  def self.notify(alert_name, payload)
    engine = ActAsNotified::Dispatcher.new(@config, alert_name, payload)

    return if engine.notifiers.nil?

    # find the recipients of this alert
    list = []
    engine.notifiers.each do |item|
      recipient = item.recipient
      raise ::ArgumentError, "payload doesn't have '#{recipient}' method" unless payload.respond_to? recipient

      first_cut_list = payload.send(recipient)
      list << engine.filter_list(first_cut_list)
    end

  end

  class Config
    attr_reader :hooks
    attr_reader :channels
    attr_reader :scopes
    attr_reader :alerts

    def channels_by_group(group)
      @channels.values.select { |x| x.group == group }
    end

    class Builder

      def initialize(&block)
        @config = ActAsNotified::Config.new
        raise BadConfiguration, 'no OptInProvider configured' if ActAsNotified.opt_in_provider.nil?

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

      def scope(name, klass: nil, constructor: nil, &block)
        scopes = @config.instance_variable_get(:@scopes) || {}

        raise BadConfiguration, "scope '#{name}' already defined" if scopes.include? name

        scope = ActAsNotified::Scope.new(@config, name, klass: klass, constructor: constructor)
        scope.instance_eval(&block)

        scopes[name] = scope

        @config.instance_variable_set(:@scopes, scopes)
        scope
      end

    end

  end
end
