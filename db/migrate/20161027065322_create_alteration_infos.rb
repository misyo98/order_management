class CreateAlterationInfos < ActiveRecord::Migration
  def change
    create_table :alteration_infos do |t|
      t.integer :profile_id
      t.integer :category_id
      t.string :manufacturer_id
      t.text :comment

      t.timestamps null: false
    end
  end
end
