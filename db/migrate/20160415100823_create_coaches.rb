class CreateCoaches < ActiveRecord::Migration
  def change
    create_table :coaches do |t|
      t.string :uuid, limit: 36, null: false
      t.string :phone, limit: 20, null: false
      t.string :name, limit: 50, null: false
      t.string :headshot, limit: 50
      t.string :portrait, limit: 50
      t.string :gender_cd, limit: 6, null: false
      t.string :title, limit: 50, null: false
      t.integer :starting_price, null: false
      t.string :short_description, limit: 2000
      t.text :description
      t.boolean :featured, default: false, null: false
      t.string :state, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
