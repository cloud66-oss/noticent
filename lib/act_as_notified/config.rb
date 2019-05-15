require 'act_as_notified/payloads'

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

    end

    def validate
      # TODO: Validate
    end

  end
end
