class CreateLineItemStateTransitions < ActiveRecord::Migration
  def change
    create_table :line_item_state_transitions do |t|
      t.references :line_item, index: true, foreign_key: true
      t.string :namespace
      t.string :event
      t.string :from
      t.string :to
      t.timestamp :created_at
    end
  end
end
