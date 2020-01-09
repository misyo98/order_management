class CreateProfileImages < ActiveRecord::Migration
  def change
    create_table :profile_images do |t|
      t.integer :measurement_profile_id
      t.string :image

      t.timestamps null: false
    end
  end
end
