# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :opt_ins, force: true do |t|
    t.integer :recipient_id
    t.integer :entity_id
    t.string :scope
    t.string :alert_name
    t.string :channel_name

    t.timestamps
  end

  create_table :recipients, force: true do |t|
    t.string :email

    t.timestamps
  end

end