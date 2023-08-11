class AddDetailsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :card_id, :string
    add_column :users, :work_start_time, :datetime
    add_column :users, :work_end_time, :datetime
  end
end
