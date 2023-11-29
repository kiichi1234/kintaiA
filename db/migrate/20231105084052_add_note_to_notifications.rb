class AddNoteToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :note, :text
  end
end
