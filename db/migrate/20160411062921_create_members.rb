class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :uuid, limit: 36, null: false
      t.references :club, null: false
      t.references :card, null: false
      t.decimal :original_price, precision: 7, scale: 2, default: 0, null: false
      t.decimal :actual_price, precision: 7, scale: 2, default: 0, null: false
      t.string :number, limit: 100, null: false
      t.decimal :amount, precision: 7, scale: 2, default: 0, null: false
      t.date :issued_at, null: false
      t.date :expired_at, null: false
      t.text :remarks
      t.string :state, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
