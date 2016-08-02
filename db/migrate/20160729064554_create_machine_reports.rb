class CreateMachineReports < ActiveRecord::Migration
  def change
    create_table :machine_reports do |t|
      t.references :machine, null: false
      t.integer :frame_number, null: false
      t.integer :frame_type, null: false
      t.integer :gprs_intensity, limit: 1, null: false
      t.references :machine_dispensation, null: false
      t.boolean :success, null: false
      t.integer :error_code, limit: 1, null: false
      t.timestamps null: false
    end
  end
end
