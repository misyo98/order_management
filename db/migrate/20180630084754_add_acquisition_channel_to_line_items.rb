class AddAcquisitionChannelToLineItems < ActiveRecord::Migration
  def up
    add_column :line_items, :acquisition_channel, :string

    column_params = { name: 'acquisition_channel', label: 'Acquisition channel', order: 78 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    remove_column :line_items, :acquisition_channel

    Column.where(columnable_type: 'LineItemScope', name: 'acquisition_channel').delete_all
  end
end
