class AddAcquisitionChannelToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :acquisition_channel, :string
  end
end
