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
    attr_reader :scopers
    attr_reader :recipients
    attr_reader :aliases
    attr_reader :hooks

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
        @payloads = ActAsNotified::Payloads.new
        @payloads.instance_eval(&block)

        @config.instance_variable_set(:@payloads, @payloads)
        @payloads
      end

      def for_scopes(&block)
        @scopers = ActAsNotified::Scopers.new
        @scopers.instance_eval(&block)

        @config.instance_variable_set(:@scopers, @scopers)
        @scopers
      end

      def recipients(type, &block)
        recipients = ActAsNotified::Recipients.new
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

    end

    def validate
      # TODO: Validate
    end

  end
end
