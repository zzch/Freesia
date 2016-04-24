class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uuid, limit: 36, null: false
      t.string :type_cd, limit: 20, null: false
      t.boolean :supervisor, default: false, null: false
      t.string :phone, limit: 20
      t.string :first_name, limit: 50
      t.string :last_name, limit: 50
      t.string :gender_cd, limit: 6
      t.date :birthday
      t.string :portrait, limit: 100
      t.string :token, limit: 22
      t.string :state, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
