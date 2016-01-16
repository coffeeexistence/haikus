class CreateHaikus < ActiveRecord::Migration
  def change
    create_table :haikus do |t|

      t.timestamps null: false
    end
  end
end
