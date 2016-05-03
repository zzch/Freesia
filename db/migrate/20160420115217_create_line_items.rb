class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.references :club, null: false
      t.references :tab, null: false
      t.string :type_cd, limit: 20, null: false
      t.references :bay
      t.references :product
      t.references :course
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :quantity
      t.decimal :amount, precision: 7, scale: 2
      t.decimal :total_amount, precision: 7, scale: 2
      t.string :name, limit: 200
      t.string :charge_method_cd, limit: 20
      t.string :pay_method_cd, limit: 20
      t.references :member
      t.timestamps null: false
    end
  end
end
