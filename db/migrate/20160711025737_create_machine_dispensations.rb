class CreateMachineDispensations < ActiveRecord::Migration
  def change
    create_table :machine_dispensations do |t|
      t.references :machine, null: false
      t.references :club, null: false
      t.references :bay, null: false
      t.integer :amount, null: false
      t.datetime :requested_at, null: false
      t.datetime :responsed_at
      t.datetime :confirmed_at
      t.string :state, null: false
      t.timestamps null: false
    end
  end
end
