class AddDetailsToBases < ActiveRecord::Migration[5.1]
  def change
    add_column :bases, :base_number, :integer
    add_column :bases, :base_type, :string
  end
end
