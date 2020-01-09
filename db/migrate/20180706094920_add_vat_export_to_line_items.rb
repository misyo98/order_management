class AddVatExportToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :vat_export, :boolean
  end
end
