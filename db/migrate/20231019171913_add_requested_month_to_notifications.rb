class AddRequestedMonthToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :requested_month, :date
  end
end
