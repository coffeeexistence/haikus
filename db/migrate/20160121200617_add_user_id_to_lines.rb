class AddUserIdToLines < ActiveRecord::Migration
  def change
    add_column :lines, :user_id, :integer
    add_index :lines, :user_id
  end
end
