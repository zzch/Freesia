class CreateServiceExceptions < ActiveRecord::Migration
  def change
    create_table :service_exceptions do |t|
      t.string :module_cd, limit: 20, null: false
      t.integer :caller_id
      t.string :name, limit: 200, null: false
      t.text :message, :backtrace
      t.timestamps null: false
    end
  end
end
