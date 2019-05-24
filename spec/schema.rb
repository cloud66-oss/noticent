# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :opt_ins, force: true do |t|
    t.integer :entity_id
    t.string :scope
    t.string :alert_name
    t.string :channel_name

    t.timestamps
  end

end