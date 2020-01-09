class AddDefaultValueToUrgentField < ActiveRecord::Migration
  def change
    change_column :alteration_summaries, :urgent, :boolean, default: 0
  end
end
