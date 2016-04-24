class CreateOperators < ActiveRecord::Migration
  def change
    create_table :operators do |t|
      t.references :club, null: false
      t.references :role, null: false
      t.string :account, limit: 16, null: false
      t.string :hashed_password, limit: 100, null: false
      t.string :name, limit: 50, null: false
      t.string :phone, limit: 20, null: false
      t.string :state, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
