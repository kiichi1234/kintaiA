class AddSourceToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :source, :string
  end
end
