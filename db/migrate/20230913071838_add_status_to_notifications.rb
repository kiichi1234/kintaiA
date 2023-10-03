class AddStatusToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :status, :string
  end
end
