class ChangeAlterationTailorServicesDefaultPrice < ActiveRecord::Migration
  def up
    change_column :alteration_service_tailors, :price, :decimal, precision: 6, scale: 2, default: nil
  end

  def down
    change_column :alteration_service_tailors, :price, :decimal, precision: 6, scale: 2, default: 0
  end
end
