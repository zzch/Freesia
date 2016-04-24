class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.string :uuid, limit: 36, null: false
      t.references :club, null: false
      t.references :user, null: false
      t.references :member, null: false
      t.string :role_cd, limit: 20, null: false
      t.string :state, limit: 20, null: false
      t.timestamps null: false
    end
  end
end
