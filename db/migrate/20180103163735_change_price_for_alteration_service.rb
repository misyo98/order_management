class ChangePriceForAlterationService < ActiveRecord::Migration
  def change
    change_column :alteration_service_tailors, :price, :decimal, precision: 6, scale: 2, default: 0
  end
end
