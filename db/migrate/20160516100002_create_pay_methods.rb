class CreatePayMethods < ActiveRecord::Migration
  def change
    create_table :pay_methods do |t|
      t.references :club
      t.string :type_cd, limit: 20, null: false
      t.string :name, limit: 50, null: false
      t.timestamps null: false
    end
  end
end
