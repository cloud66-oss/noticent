# frozen_string_literal: true

module ActAsNotified
  class Alert

    attr_reader :name
    attr_reader :scope
    attr_reader :notifiers

    def initialize(config, name, scope: [:all])
      ActAsNotified::Alert.validate_scope(config, scope)

      @config = config
      @name = name
      @scope = scope
    end

    def notify(recipient, template: '')
      raise BadConfiguration, 'no recipients are defined yet' if @config.recipients.nil?
      raise BadConfiguration, "recipient '#{recipient}' not defined" unless @config.recipients.include? recipient

      notifiers = @config.instance_variable_get(:@notifiers) || {}
      raise BadConfiguration, "a notify is already defined for '#{recipient}'" unless notifiers[recipient].nil?

      notifiers[recipient] = ActAsNotified::Alert::Notifier.new(@config, recipient, template: template)
      @config.instance_variable_set(:@notifiers, notifiers)

      notifiers[recipient]
    end

    def self.validate_scope(config, scope)
      if config.scopes.nil? || config.scopes.values.empty?
        return if scope == [:all]

        raise BadConfiguration, 'invalid or undefined scope. only :all is allowed (no other scopes are defined)'
      end

      raise BadConfiguration, 'cannot have all mixed with other scopes' if scope.include?(:all) && scope.count != 1

      raise BadConfiguration, "invalid or undefined scope. valid values are #{config.scopes.values.keys.join(', ')} and all" unless (scope - config.scopes.values.keys).empty?
    end

    class Notifier

      attr_reader :recipient
      attr_reader :group
      attr_reader :template

      def initialize(config, recipient, template: '')
        @recipient = recipient
        @config = config
        @template = template
      end

      def on(group)
        @group = group
      end

    end

  end
end