class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :uuid, limit: 36, null: false
      t.references :club, null: false
      t.references :course, null: false
      t.references :user, null: false
      t.decimal :original_price, precision: 7, scale: 2, null: false
      t.decimal :actual_price, precision: 7, scale: 2, null: false
      t.integer :total_lessons, limit: 2, null: false
      t.datetime :issued_at, null: false
      t.datetime :expired_at, null: false
      t.string :state, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
