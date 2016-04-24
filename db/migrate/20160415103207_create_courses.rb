class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :uuid, limit: 36, null: false
      t.references :club, null: false
      t.references :coach, null: false
      t.string :type_cd, limit: 20, null: false
      t.string :name, limit: 500, null: false
      t.decimal :price, precision: 7, scale: 2, null: false
      t.integer :maximum_lessons, limit: 2, null: false
      t.integer :maximum_students, limit: 2, null: false
      t.integer :valid_months, limit: 1, null: false
      t.text :description
      t.timestamps null: false
    end
  end
end
