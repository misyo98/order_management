class AddFabricTrackingNumberToLineItems < ActiveRecord::Migration
  def up
    add_column :line_items, :fabric_tracking_number, :string, after: :outbound_tracking_number
  
    column_params = { name: 'fabric_tracking_number', label: 'Fabric Tracking Number', order: 115 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end
  
  def down    
    remove_column :line_items, :fabric_tracking_number
    Column.where(columnable_type: 'LineItemScope', name: 'fabric_tracking_number').delete_all
  end
end
