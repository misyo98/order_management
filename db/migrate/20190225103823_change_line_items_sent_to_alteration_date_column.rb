class ChangeLineItemsSentToAlterationDateColumn < ActiveRecord::Migration
  def up
    change_column :line_items, :sent_to_alteration_date, :datetime
  end

  def down
    change_column :line_items, :sent_to_alteration_date, :date
  end
end
