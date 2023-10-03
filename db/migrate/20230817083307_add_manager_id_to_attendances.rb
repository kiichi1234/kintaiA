class AddManagerIdToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :manager_id, :integer
  end
end
