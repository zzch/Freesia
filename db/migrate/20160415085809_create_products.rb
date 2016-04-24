class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :uuid, limit: 36, null: false
      t.references :club, null: false
      t.references :category, null: false
      t.string :name, limit: 500, null: false
      t.string :image, limit: 50
      t.decimal :price, precision: 7, scale: 2, null: false
      t.text :description
      t.string :state, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
