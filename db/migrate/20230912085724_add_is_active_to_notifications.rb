class AddIsActiveToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :is_active, :boolean, default: true, null: false
  end
end
