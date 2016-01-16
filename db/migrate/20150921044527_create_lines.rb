class CreateLines < ActiveRecord::Migration
  def change
    create_table :lines do |t|
      t.integer :haiku_id
      t.string :content

      t.timestamps null: false
    end
  end
end
