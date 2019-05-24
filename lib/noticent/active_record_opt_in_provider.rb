# frozen_string_literal: true

module Noticent
  # should be used only for testing
  class ActiveRecordOptInProvider
    def opt_in(recipient_id:, scope:, entity_id:, alert_name:, channel_name:)
      Noticent::OptIn.create(recipient_id: recipient_id, scope: scope, entity_id: entity_id, alert_name: alert_name, channel_name: channel_name)
    end

    def opt_out(recipient_id:, scope:, entity_id:, alert_name:, channel_name:)
      Noticent::OptIn.where(recipient_id: recipient_id, scope: scope, entity_id: entity_id, alert_name: alert_name, channel_name: channel_name).delete
    end

    def opted_in?(recipient_id:, scope:, entity_id:, alert_name:, channel_name:)
      Noticent::OptIn.where(recipient_id: recipient_id, scope: scope, entity_id: entity_id, alert_name: alert_name, channel_name: channel_name).count != 0
    end
  end
end
