class CreateFabricNotifications < ActiveRecord::Migration
  def change
    create_table :fabric_notifications do |t|
      t.string :fabric_code
      t.integer :event

      t.timestamps null: false
    end
  end
end
