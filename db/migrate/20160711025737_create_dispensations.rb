class CreateDispensations < ActiveRecord::Migration
  def change
    create_table :dispensations do |t|
      t.references :machine, null: false
      t.integer :amount, null: false
      t.datetime :requested_at, null: false
      t.datetime :responsed_at
      t.datetime :confirmed_at
      t.string :state, null: false
      t.timestamps null: false
    end
  end
end
