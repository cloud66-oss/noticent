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
        time_now = Time.now.utc
        formatted_time_now = ::Noticent::RailsVersion.rails_7_or_greater? ? time_now.to_fs(:db) : time_now.to_s(:db)
        # fetch all permutations of recipient and entity id
        permutations = Noticent::OptIn.distinct
                                      .where('recipient_id IN (?)', recipient_ids)
                                      .pluck(:entity_id, :recipient_id)

        return if permutations.empty?

        values = permutations.map { |e, r| "('#{scope}','#{alert_name}', #{e}, #{r}, '#{channel}', '#{formatted_time_now}', '#{formatted_time_now}')" }.join(',')
        ActiveRecord::Base.connection.execute("INSERT INTO opt_ins (scope, alert_name, entity_id, recipient_id, channel_name, created_at, updated_at) VALUES #{values}")
      end
    end

    def remove_alert(scope:, alert_name:)
      Noticent::OptIn.where('scope = ? AND alert_name = ?', scope, alert_name).destroy_all
    end

    def remove_entity(scope:, entity_id:)
      Noticent::OptIn.where('scope = ? AND entity_id = ?', scope, entity_id).destroy_all
    end

    def remove_recipient(recipient_id:)
    Noticent::OptIn.where(recipient_id: recipient_id).destroy_all
    end

  end
end
