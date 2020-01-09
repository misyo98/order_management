class AddExpectedTimesToStatesTimelines < ActiveRecord::Migration
  def change
    add_column :states_timelines, :expected_delivery_time_uk, :integer, after: :allowed_time_sg
    add_column :states_timelines, :expected_delivery_time_sg, :integer, after: :expected_delivery_time_uk
  end
end
