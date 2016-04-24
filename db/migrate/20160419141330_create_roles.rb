class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.references :club, null: false
      t.string :name, limit: 50, null: false
      t.boolean :omnipotent, default: false, null: false
      t.boolean :manage_role, default: false, null: false
      t.boolean :manage_operator, default: false, null: false
      t.boolean :manage_bay, default: false, null: false
      t.boolean :manage_card, default: false, null: false
      t.boolean :manage_saleman, default: false, null: false
      t.boolean :manage_product, default: false, null: false
      t.boolean :manage_coach, default: false, null: false
      t.boolean :manage_course, default: false, null: false
      t.boolean :create_member, default: false, null: false
      t.boolean :update_member, default: false, null: false
      t.boolean :cancel_member, default: false, null: false
      t.boolean :trash_member, default: false, null: false
      t.timestamps null: false
    end
  end
end
