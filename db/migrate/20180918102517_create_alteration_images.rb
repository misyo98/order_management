class CreateAlterationImages < ActiveRecord::Migration
  def up
    create_table :alteration_images do |t|
      t.integer :alteration_summary_id
      t.string :image

      t.timestamps null: false
    end
  end
  
  def down
    drop_table :alteration_images
  end
end
