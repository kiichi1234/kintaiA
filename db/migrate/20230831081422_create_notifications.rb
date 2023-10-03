class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.references :user, foreign_key: true
      t.references :manager, foreign_key: { to_table: :users }
      t.references :attendance, foreign_key: true
      t.text :content
      t.boolean :read

      t.timestamps
    end
  end
end

