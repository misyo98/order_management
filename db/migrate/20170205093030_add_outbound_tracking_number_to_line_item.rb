class AddOutboundTrackingNumberToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :outbound_tracking_number, :string, after: :tracking_number
  end
end
