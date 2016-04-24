class CreateBayUseables < ActiveRecord::Migration
  def change
    create_table :bay_useables do |t|
      t.references :club, null: false
      t.references :card, null: false
      t.references :bay_tag, null: false
      t.timestamps null: false
    end
  end
end
