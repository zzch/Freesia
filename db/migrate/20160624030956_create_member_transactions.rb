class CreateMemberTransactions < ActiveRecord::Migration
  def change
    create_table :member_transactions do |t|
      t.references :club, null: false
      t.references :member, null: false
      t.string :type_cd, limit: 20, null: false
      t.string :action_cd, limit: 20, null: false
      t.references :tab
      t.decimal :before_amount, precision: 7, scale: 2, null: false
      t.decimal :amount, precision: 7, scale: 2, null: false
      t.decimal :after_amount, precision: 7, scale: 2, null: false
      t.string :items, limit: 100
      t.timestamps null: false
    end
  end
end
