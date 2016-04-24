class CreateTrainings < ActiveRecord::Migration
  def change
    create_table :trainings do |t|
      t.string :uuid, limit: 36, null: false
      t.references :club, null: false
      t.references :user, null: false
      t.references :lesson, null: false
      t.integer :rating, limit: 1
      t.string :state, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
