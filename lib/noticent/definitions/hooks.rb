# frozen_string_literal: true

module Noticent
  module Definitions
    class Hooks
      VALID_STEPS = %i[pre_alert_registration post_alert_registration pre_channel_registration post_channel_registration].freeze

      def add(step, klass)
        raise BadConfiguration, "invalid step. valid values are #{VALID_STEPS}" unless VALID_STEPS.include? step

        storage[step] = [] if storage[step].nil?
        storage[step] << klass
      end

      def fetch(step)
        raise ::ArgumentError, "invalid step. valid values are #{VALID_STEPS}" unless VALID_STEPS.include? step

        storage[step]
      end

      def run(step, chan)
        chain = fetch(step)
        return if chain.nil?

        chain.each do |to_run|
          to_run.send(step, chan) if to_run.respond_to? step
        end
      end

      private

      def storage
        @storage ||= {}
      end
    end
  end
end
