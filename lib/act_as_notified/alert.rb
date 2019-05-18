# frozen_string_literal: true

module ActAsNotified
  class Alert

    attr_reader :name
    attr_reader :scope
    attr_reader :notifiers

    def initialize(config, name, scope: [:all])
      @config = config
      @name = name
      @scope = scope
    end

    def notify(recipient, template: '')
      notifiers = @config.instance_variable_get(:@notifiers) || {}
      raise BadConfiguration, "a notify is already defined for '#{recipient}'" unless notifiers[recipient].nil?

      notifiers[recipient] = ActAsNotified::Alert::Notifier.new(@config, recipient, template: template)
      @config.instance_variable_set(:@notifiers, notifiers)

      notifiers[recipient]
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