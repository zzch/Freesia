class CreateBayPrices < ActiveRecord::Migration
  def change
    create_table :bay_prices do |t|
      t.references :club, null: false
      t.references :card, null: false
      t.references :bay, null: false
      t.decimal :weekday_price_per_hour, precision: 7, scale: 2
      t.decimal :holiday_price_per_hour, precision: 7, scale: 2
      t.decimal :weekday_price_per_bucket, precision: 7, scale: 2
      t.decimal :holiday_price_per_bucket, precision: 7, scale: 2
      t.timestamps null: false
    end
  end
end
