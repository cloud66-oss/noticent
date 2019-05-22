module Noticent
	module Testing
		# should be used only for testing
		class InMemOptInProvider

			attr_reader :store

			def initialize
				@store = []
			end

			def opt_in(scope:, entity_id:, alert_name:, channel_name:)
				@store << key(scope: scope, entity_id: entity_id, alert_name: alert_name, channel_name: channel_name)
				@store.uniq!
			end

			def opt_out(scope:, entity_id:, alert_name:, channel_name:)
				@store = @store - [key(scope: scope, entity_id: entity_id, alert_name: alert_name, channel_name: channel_name)]
			end

			def opted_in?(scope:, entity_id:, alert_name:, channel_name:)
				@store.include? key(scope: scope, entity_id: entity_id, alert_name: alert_name, channel_name: channel_name)
			end

			private

			def key(scope:, entity_id:, alert_name:, channel_name:)
				"#{scope}:#{entity_id}:#{alert_name}:#{channel_name}"
			end
		end
	end
end