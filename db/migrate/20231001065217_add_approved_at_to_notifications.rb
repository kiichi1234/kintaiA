class AddApprovedAtToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :approved_at, :datetime
  end
end
