class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :model_cd, limit: 20, null: false
      t.string :serial_number, limit: 10, null: false
      t.date :manufactured_at, null: false
      t.references :club
      t.references :bay
      t.boolean :out_of_stock
      t.text :remarks
      t.string :state, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
