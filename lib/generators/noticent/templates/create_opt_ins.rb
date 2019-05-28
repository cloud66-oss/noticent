class CreateOptIns < ActiveRecord::Migration[5.2]
  def change
    create_table :opt_ins, force: true do |t|
      t.integer :recipient_id, null: false
      t.integer :entity_id, null: false
      t.string :scope, null: false
      t.string :alert_name, null: false
      t.string :channel_name, null: false

      t.timestamps
    end

    add_index :opt_ins, %i[recipient_id entity_id scope alert_name channel_name], unique: true, name: :unique_composite_key
  end
end