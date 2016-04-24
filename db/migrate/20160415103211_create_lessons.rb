class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.string :uuid, limit: 36, null: false
      t.references :club, null: false
      t.references :course, null: false
      t.string :name, limit: 500, null: false
      t.datetime :started_at, null: false
      t.datetime :finished_at, null: false
      t.integer :maximum_students, limit: 2, null: false
      t.timestamps null: false
    end
  end
end
