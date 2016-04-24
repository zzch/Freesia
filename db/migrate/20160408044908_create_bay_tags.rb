class CreateBayTags < ActiveRecord::Migration
  def change
    create_table :bay_tags do |t|
      t.references :club, null: false
      t.string :name, limit: 50, null: false
      t.timestamps null: false
    end
  end
end
