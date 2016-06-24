class CreateTabs < ActiveRecord::Migration
  def change
    create_table :tabs do |t|
      t.string :uuid, limit: 36, null: false
      t.references :club, null: false
      t.references :user, null: false
      t.integer :sequence, null: false
      t.datetime :entrance_time, null: false
      t.datetime :departure_time
      t.integer :balls_per_bucket, null: false
      t.integer :minimum_charging_minutes, null: false
      t.integer :unit_charging_minutes, null: false
      t.integer :maximum_discard_minutes, null: false
      t.string :state, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
