class CreateAlterationServiceTailors < ActiveRecord::Migration
  def change
    create_table :alteration_service_tailors do |t|
      t.references :alteration_service
      t.references :alteration_tailor
      t.integer :price
      t.timestamps null: false
    end
  end
end
