class AddDropdownListReferenceToFabricOptionAndFabricOptionValues < ActiveRecord::Migration
  def change
    add_column :fabric_options, :using_dropdown_list, :boolean, after: :manufacturer, index: true
    add_column :fabric_option_values, :active, :boolean, after: :manufacturer
    add_column :fabric_option_values, :manufacturer_code, :string, after: :active
    add_reference :fabric_options, :dropdown_list, after: :fabric_tab_id, index: true
    add_reference :fabric_option_values, :dropdown_list, after: :fabric_option_id, index: true
  end
end
