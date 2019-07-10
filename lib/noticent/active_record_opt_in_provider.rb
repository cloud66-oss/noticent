# frozen_string_literal: true

module Noticent
  # should be used only for testing
  class ActiveRecordOptInProvider
    def opt_in(recipient_id:, scope:, entity_id:, alert_name:, channel_name:)
      Noticent::OptIn.create!(recipient_id: recipient_id, scope: scope, entity_id: entity_id, alert_name: alert_name, channel_name: channel_name)
    end

    def opt_out(recipient_id:, scope:, entity_id:, alert_name:, channel_name:)
      Noticent::OptIn.where(recipient_id: recipient_id, scope: scope, entity_id: entity_id, alert_name: alert_name, channel_name: channel_name).destroy_all
    end

    def opted_in?(recipient_id:, scope:, entity_id:, alert_name:, channel_name:)
      Noticent::OptIn.where(recipient_id: recipient_id, scope: scope, entity_id: entity_id, alert_name: alert_name, channel_name: channel_name).count != 0
    end

    def add_alert(scope:, alert_name:, recipient_ids:, channel:)
      ActiveRecord::Base.transaction do
        now = Time.now.utc.to_s(:db)
        # fetch all permutations of recipient and entity id
        permutations = Noticent::OptIn.distinct
                                      .where('recipient_id IN (?)', recipient_ids)
                                      .pluck(:entity_id, :recipient_id)

        return if permutations.empty?

        values = permutations.map { |e, r| "('#{scope}','#{alert_name}', #{e}, #{r}, '#{channel}', '#{now}', '#{now}')" }.join(',')
        ActiveRecord::Base.connection.execute("INSERT INTO opt_ins (scope, alert_name, entity_id, recipient_id, channel_name, created_at, updated_at) VALUES #{values}")
      end
    end

    def remove_alert(scope:, alert_name:)
      Noticent::OptIn.where('scope = ? AND alert_name = ?', scope, alert_name).destroy_all
    end

  end
end
