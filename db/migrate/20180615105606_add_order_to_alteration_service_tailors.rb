class AddOrderToAlterationServiceTailors < ActiveRecord::Migration
  def change
    add_column :alteration_service_tailors, :order, :integer, default: 0
  end
end
