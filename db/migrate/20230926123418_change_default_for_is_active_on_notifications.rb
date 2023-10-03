class ChangeDefaultForIsActiveOnNotifications < ActiveRecord::Migration[5.1]
  def up
    change_column_default :notifications, :is_active, false
    Notification.update_all(is_active: false)
  end

  def down
    change_column_default :notifications, :is_active, true
  end
end
