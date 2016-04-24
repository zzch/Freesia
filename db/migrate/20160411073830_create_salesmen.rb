class CreateSalesmen < ActiveRecord::Migration
  def change
    create_table :salesmen do |t|
      t.string :uuid, limit: 36, null: false
      t.references :club, null: false
      t.string :phone, limit: 20, null: false
      t.string :name, limit: 50, null: false
      t.timestamps null: false
    end
  end
end
