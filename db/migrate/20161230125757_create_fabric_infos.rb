class CreateFabricInfos < ActiveRecord::Migration
  def change
    create_table :fabric_infos do |t|
      t.string :fabric_code
      t.string :m_fabric_code
      t.string :fabric_type

      t.timestamps null: false
    end
  end
end
