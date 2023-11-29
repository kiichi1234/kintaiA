class AddOvertimeFieldsToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :scheduled_end, :time
    add_column :notifications, :next_day, :boolean
  end
end
