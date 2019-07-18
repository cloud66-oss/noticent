# frozen_string_literal: true

module Noticent
  def self.configure(options = {}, &block)
    if ENV["NOTICENT_RSPEC"] == "1"
      options = options.merge(
        base_module_name: "Noticent::Testing",
        base_dir: File.expand_path("#{File.dirname(__FILE__)}/../../testing"),
        halt_on_error: true,
      )
    end

    @config = Noticent::Config::Builder.new(options, &block).build
    @config.validate!

    # construct dynamics
    @config.create_dynamics

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

  # recipient is the recipient object id
  # entities is an array of all entity ids this recipient needs to opt in based on the alert defaults
  # scope is the name of the scope these entities belong to
  def self.setup_recipient(recipient_id:, scope:, entity_ids:)
    raise ArgumentError, "no scope named '#{scope}' found" if @config.scopes[scope].nil?

    alerts = @config.alerts_by_scope(scope)

    alerts.each do |alert|
      channels = @config.alert_channels(alert.name)

      channels.each do |channel|
        next unless alert.default_for(channel.name)

        entity_ids.each do |entity_id|
          @config.opt_in_provider.opt_in(recipient_id: recipient_id,
                                         scope: scope,
                                         entity_id: entity_id,
                                         alert_name: alert.name,
                                         channel_name: channel.name)
        end
      end
    end
  end

  class Config
    attr_reader :hooks
    attr_reader :channels
    attr_reader :scopes
    attr_reader :alerts
    attr_reader :products
    attr_reader :channel_groups

    def initialize(options = {})
      @options = options
      @products = {}
    end

    def channels_by_group(group)
      return [] if @channels.nil?

      @channels.values.select { |x| x.group == group }
    end

    def alert_channels(alert_name)
      alert = @alerts[alert_name]
      raise ArgumentError, "no alert #{alert_name} found" if alert.nil?
      return [] if alert.notifiers.nil?

      alert.notifiers.values.collect { |notifier| channels_by_group(notifier.channel_group).uniq }.uniq.flatten
    end

    def products_by_alert(alert_name)
      alert = @alerts[alert_name]
      raise ArgumentError "no alert #{alert_name} found" if alert.nil?

      alert.products
    end

    def alerts_by_scope(scope)
      return [] if @alerts.nil?

      @alerts.values.select { |x| x.scope.name == scope }
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
      @options[:halt_on_error].nil? ? false : @options[:halt_on_error]
    end

    def skip_alert_with_no_subscribers
      @options[:skip_alert_with_no_subscribers].nil? ? false : @options[:skip_alert_with_no_subscribers]
    end

    def default_value
      @options[:default_value].nil? ? false : @options[:default_value]
    end

    def use_sub_modules
      @options[:use_sub_modules].nil? ? false : @options[:use_sub_modules]
    end

    def payload_dir
      File.join(base_dir, "payloads")
    end

    def scope_dir
      File.join(base_dir, "scopes")
    end

    def channel_dir
      File.join(base_dir, "channels")
    end

    def view_dir
      File.join(base_dir, "views")
    end

    def create_dynamics
      return if alerts.nil?

      alerts.keys.each do |alert|
        const_name = "ALERT_#{alert.to_s.upcase}"
        next if Noticent.const_defined?(const_name)

        Noticent.const_set(const_name, alert)
      end
    end

    def validate!
      # check all scopes
      scopes&.values&.each(&:validate!)
      alerts&.values&.each(&:validate!)
    end

    class Builder
      def initialize(options = {}, &block)
        @options = options
        @config = Noticent::Config.new(options)
        raise BadConfiguration, "no OptInProvider configured" if @config.opt_in_provider.nil?

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

      def skip_alert_with_no_subscribers=(value)
        @options[:skip_alert_with_no_subscribers] = value
      end

      def use_sub_modules=(value)
        @options[:use_sub_modules] = value
      end

      def hooks
        if @config.hooks.nil?
          @config.instance_variable_set(:@hooks, Noticent::Definitions::Hooks.new)
        else
          @config.hooks
        end
      end

      def product(name, &block)
        products = @config.instance_variable_get(:@products) || {}

        raise BadConfiguration, "product #{name} already defined" if products[name]

        product = Noticent::Definitions::Product.new(@config, name)
        hooks.run(:pre_product_registration, product)
        product.instance_eval(&block) if block_given?
        hooks.run(:post_product_registration, product)

        products[name] = product

        @config.instance_variable_set(:@products, products)

        product
      end

      def channel(name, group: :default, klass: nil, &block)
        channels = @config.instance_variable_get(:@channels) || {}
        channel_groups = @config.instance_variable_get(:@channel_groups) || []

        raise BadConfiguration, "channel '#{name}' already defined" if channels.include? name
        raise BadConfiguration, "a channel group named '#{group}' already exists. channels and channel groups cannot have duplicates" if channel_groups.include? name

        channel_groups << group

        channel = Noticent::Definitions::Channel.new(@config, name, group: group, klass: klass)
        hooks.run(:pre_channel_registration, channel)
        channel.instance_eval(&block) if block_given?
        hooks.run(:post_channel_registration, channel)

        channels[name] = channel

        @config.instance_variable_set(:@channels, channels)
        @config.instance_variable_set(:@channel_groups, channel_groups.uniq)
        channel
      end

      def scope(name, payload_class: nil, check_constructor: true, &block)
        scopes = @config.instance_variable_get(:@scopes) || {}

        raise BadConfiguration, "scope '#{name}' already defined" if scopes.include? name

        scope = Noticent::Definitions::Scope.new(@config, name, payload_class: payload_class, check_constructor: check_constructor)
        scope.instance_eval(&block)

        scopes[name] = scope

        @config.instance_variable_set(:@scopes, scopes)
        scope
      end
    end
  end
end
