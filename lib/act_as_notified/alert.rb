# frozen_string_literal: true

module ActAsNotified
  class Alert

    attr_reader :name
    attr_reader :scope

    def initialize(config, name, scope: [:all])
      ActAsNotified::Alert.validate_scope(config, scope)

      @config = config
      @name = name
      @scope = scope
    end

    def notify(recipient)
      raise BadConfiguration, "recipient '#{recipient}' not defined" unless @config.recipients.include? recipient
    end

    private

    def self.validate_scope(config, scope)
      if config.scopes.nil? || config.scopes.values.empty?
        return if scope == [:all]

        raise BadConfiguration, 'invalid or undefined scope. only :all is allowed (no other scopes are defined)'
      end

      raise BadConfiguration, 'cannot have all mixed with other scopes' if scope.include?(:all) && scope.count != 1

      raise BadConfiguration, "invalid or undefined scope. valid values are #{config.scopes.values.keys.join(', ')} and all" unless (scope - config.scopes.values.keys).empty?
    end

  end
end