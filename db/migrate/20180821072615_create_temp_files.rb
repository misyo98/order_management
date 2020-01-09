class CreateTempFiles < ActiveRecord::Migration
  def up
    create_table :temp_files do |t|

      t.string :attachment
      t.timestamps null: false
    end
  end
  
  def down
    drop_table :temp_files
  end
end
