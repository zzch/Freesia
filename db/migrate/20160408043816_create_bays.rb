class CreateBays < ActiveRecord::Migration
  def change
    create_table :bays do |t|
      t.string :uuid, limit: 36, null: false
      t.references :club, null: false
      t.references :tab
      t.string :name, limit: 50, null: false
      t.string :location_cd, limit: 20, null: false
      t.decimal :weekday_price_per_hour, precision: 7, scale: 2
      t.decimal :holiday_price_per_hour, precision: 7, scale: 2
      t.decimal :weekday_price_per_bucket, precision: 7, scale: 2
      t.decimal :holiday_price_per_bucket, precision: 7, scale: 2
      t.string :state, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
