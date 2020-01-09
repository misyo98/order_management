class AddValidFromToEstimatedCog < ActiveRecord::Migration
  def change
    add_column :estimated_cogs, :valid_from, :date, after: :estimated_duty
  end
end
