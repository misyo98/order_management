class CreateAlterationSummaryLineItems < ActiveRecord::Migration
  def up
    create_table :alteration_summary_line_items do |t|
      t.references :alteration_summary, index: true, foreign_key: true
      t.references :line_item, index: true, foreign_key: true

      t.timestamps null: false
    end

    AlterationSummary.reset_column_information

    AlterationSummary.find_each do |summary|
      summary.line_item_ids.each do |item_id|
        summary.alteration_summary_line_items.create(line_item_id: item_id)
      end
    end
  end

  def down
    drop_table :alteration_summary_line_items
  end
end
