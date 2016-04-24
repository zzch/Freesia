class CreateSalemanTransactions < ActiveRecord::Migration
  def change
    create_table :saleman_transactions do |t|
      t.references :club, null: false
      t.references :saleman, null: false
      t.references :member
      t.references :tab
      t.string :type_cd, limit: 20, null: false
      t.decimal :amount, precision: 7, scale: 2
      t.string :remarks, limit: 1000
      t.string :state, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
