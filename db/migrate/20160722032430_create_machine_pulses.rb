class CreateMachinePulses < ActiveRecord::Migration
  def change
    create_table :machine_pulses do |t|
      t.references :machine, null: false
      t.integer :frame_number, null: false
      t.integer :frame_type, null: false
      t.integer :gprs_intensity, limit: 1, null: false
      t.boolean :out_of_stock, null: false
      t.integer :battery, limit: 1, null: false
      t.timestamps null: false
    end
  end
end
