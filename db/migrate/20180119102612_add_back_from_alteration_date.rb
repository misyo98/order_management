class AddBackFromAlterationDate < ActiveRecord::Migration
  def change
    add_column :line_items, :back_from_alteration_date, :datetime, after: :sent_to_alteration_date
  end
end
