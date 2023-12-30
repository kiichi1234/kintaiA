class AddDefaultValuesToWorkTimes < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :work_start_time, '09:00'
    change_column_default :users, :work_end_time, '17:00'
  end
end
