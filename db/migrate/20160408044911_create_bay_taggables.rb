class CreateBayTaggables < ActiveRecord::Migration
  def change
    create_table :bay_taggables do |t|
      t.references :club, null: false
      t.references :bay, null: false
      t.references :tag, null: false
      t.timestamps null: false
    end
  end
end
