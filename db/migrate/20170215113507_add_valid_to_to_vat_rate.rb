class AddValidToToVatRate < ActiveRecord::Migration
  def change
    add_column :vat_rates, :valid_from, :date, after: :rate
  end
end
