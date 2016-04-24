class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :uuid, limit: 36, null: false
      t.references :club, null: false
      t.string :type_cd, limit: 20, null: false
      t.string :name, limit: 100, null: false
      t.integer :price, null: false
      t.integer :valid_months, limit: 1, null: false
      t.decimal :initial_amount, precision: 7, scale: 2
      t.timestamps null: false
    end
  end
end
