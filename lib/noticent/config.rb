# frozen_string_literal: true

module Noticent
  def self.configure(options = {}, &block)
    if ENV['NOTICENT_RSPEC'] == '1'
      options = options.merge(
        base_module_name: 'Noticent::Testing',
        base_dir: File.expand_path("#{File.dirname(__FILE__)}/../../testing"),
        halt_on_error: true
      )
    end

    @config = Noticent::Config::Builder.new(options, &block).build
    @config
  end

  def self.configuration
    @config || (raise Noticent::MissingConfiguration)
  end

  def self.notify(alert_name, payload)
    engine = Noticent::Dispatcher.new(@config, alert_name, payload)

    return if engine.notifiers.nil?

    engine.dispatch
  end

  class Config
    attr_reader :hooks
    attr_reader :channels
    attr_reader :scopes
    attr_reader :alerts

    def initialize(options = {})
      @options = options
    end

    def channels_by_group(group)
      @channels.values.select { |x| x.group == group }
    end

    def base_dir
      @options[:base_dir]
    end

    def base_module_name
      @options[:base_module_name]
    end

    def opt_in_provider
      @options[:opt_in_provider] || Noticent::ActiveRecordOptInProvider.new
    end

    def logger
      @options[:logger] || Logger.new(STDOUT)
    end

    def halt_on_error
      @options[:halt_on_error].nil? || false
    end

    def payload_dir
      File.join(base_dir, 'payloads')
    end

    def scope_dir
      File.join(base_dir, 'scopes')
    end

    def channel_dir
      File.join(base_dir, 'channels')
    end

    def view_dir
      File.join(base_dir, 'views')
    end

    class Builder
      def initialize(options = {}, &block)
        @options = options
        @config = Noticent::Config.new(options)
        raise BadConfiguration, 'no OptInProvider configured' if @config.opt_in_provider.nil?

        instance_eval(&block) if block_given?

        @config.instance_variable_set(:@options, @options)
      end

      def build
        @config
      end

      def base_dir=(value)
        @options[:base_dir] = value
      end

      def base_module_name=(value)
        @options[:base_module_name] = value
      end

      def opt_in_provider=(value)
        @options[:opt_in_provider] = value
      end

      def logger=(value)
        @options[:logger] = value
      end

      def halt_on_error=(value)
        @options[:halt_on_error] = value
      end

      def hooks
        if @config.hooks.nil?
          @config.instance_variable_set(:@hooks, Noticent::Definitions::Hooks.new)
        else
          @config.hooks
        end
      end

      def channel(name, group: :default, klass: nil, &block)
        channels = @config.instance_variable_get(:@channels) || {}

        raise BadConfiguration, "channel '#{name}' already defined" if channels.include? name

        channel = Noticent::Definitions::Channel.new(@config, name, group: group, klass: klass)
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

        scope = Noticent::Definitions::Scope.new(@config, name, klass: klass, constructor: constructor)
        scope.instance_eval(&block)

        scopes[name] = scope

        @config.instance_variable_set(:@scopes, scopes)
        scope
      end
    end
  end
end
