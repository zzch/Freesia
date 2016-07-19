class CreateDispensations < ActiveRecord::Migration
  def change
    create_table :dispensations do |t|
      t.references :club, null: false
      t.references :bay, null: false
      t.references :machine, null: false
      t.integer :amount, null: false
      t.datetime :started_at, null: false
      t.datetime :finished_at, null: false
      t.string :state, null: false
      t.timestamps null: false
    end
  end
end
