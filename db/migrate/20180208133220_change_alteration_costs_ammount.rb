class ChangeAlterationCostsAmmount < ActiveRecord::Migration
  def change
    change_column :alteration_summaries, :amount, :decimal, precision: 6, scale: 2, default: 0
  end
end
