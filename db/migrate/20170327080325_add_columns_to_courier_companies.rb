class AddColumnsToCourierCompanies < ActiveRecord::Migration
  def change
    add_column :courier_companies, :tracking_link, :string, after: :name
  end
end
