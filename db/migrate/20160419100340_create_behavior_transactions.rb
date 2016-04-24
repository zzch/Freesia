class CreateBehaviorTransactions < ActiveRecord::Migration
  def change
    create_table :behavior_transactions do |t|
      t.references :club, null: false
      t.references :operator, null: false
      t.references :primary_resource
      t.references :secondary_resource
      t.string :resource_cd, limit: 50, null: false
      t.string :action_cd, limit: 50, null: false
      t.string :remarks, limit: 1000
      t.timestamps null: false
    end
  end
end
