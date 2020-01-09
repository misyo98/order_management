class AddCurrencyToAlterationTailors < ActiveRecord::Migration
  def change
    add_column :alteration_tailors, :currency, :integer, default: 0
  end
end
