module Noticent
  module Testing
    # should be used only for testing
    class SqliteOptInProvider

      attr_reader :store

      def opt_in(scope:, entity_id:, alert_name:, channel_name:)
        Noticent::OptIn.create(scope: scope, entity_id: entity_id, alert_name: alert_name, channel_name: channel_name)
      end

      def opt_out(scope:, entity_id:, alert_name:, channel_name:)
        Noticent::OptIn.where(scope: scope, entity_id: entity_id, alert_name: alert_name, channel_name: channel_name).delete
      end

      def opted_in?(scope:, entity_id:, alert_name:, channel_name:)
        !Noticent::OptIn.where(scope: scope, entity_id: entity_id, alert_name: alert_name, channel_name: channel_name).first.nil?
      end

    end
  end
end