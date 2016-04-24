class CreateClubs < ActiveRecord::Migration
  def change
    create_table :clubs do |t|
      t.string :uuid, limit: 36, null: false
      t.string :name, limit: 100, null: false
      t.string :short_name, limit: 100
      t.string :code, limit: 30, null: false
      t.string :logo, limit: 100
      t.decimal :longitude, :latitude, precision: 18, scale: 15, null: false
      t.string :address, limit: 800, null: false
      t.string :phone_number, limit: 50, null: false
      t.integer :balls_per_bucket, null: false
      t.integer :minimum_charging_minutes, null: false
      t.integer :unit_charging_minutes, null: false
      t.integer :maximum_discard_minutes, null: false
      t.timestamps null: false
    end
  end
end
