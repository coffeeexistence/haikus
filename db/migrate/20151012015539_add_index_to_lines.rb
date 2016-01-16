class AddIndexToLines < ActiveRecord::Migration
  def change
    add_index :lines, :haiku_id
  end
end
