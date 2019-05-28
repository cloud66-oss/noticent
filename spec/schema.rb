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

  add_index :opt_ins, %i[recipient_id entity_id scope alert_name channel_name], unique: true, name: :unique_composite_key

  create_table :recipients, force: true do |t|
    t.string :email

    t.timestamps
  end
end
