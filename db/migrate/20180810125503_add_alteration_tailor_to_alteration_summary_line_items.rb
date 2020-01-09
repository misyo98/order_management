class AddAlterationTailorToAlterationSummaryLineItems < ActiveRecord::Migration
  def up
    add_reference :alteration_summary_line_items, :alteration_tailor, foreign_key: true, after: :line_item_id
    add_column :alteration_summary_line_items, :sent_to_alteration_date, :date
    add_column :alteration_summary_line_items, :back_from_alteration_date, :date

    AlterationSummaryLineItem.reset_column_information

    AlterationSummaryLineItem.includes(:line_item).find_each do |item_summary|
      line_item = item_summary.line_item
      item_summary.update_columns(alteration_tailor_id: line_item.alteration_tailor_id,
                                  sent_to_alteration_date: line_item.sent_to_alteration_date,
                                  back_from_alteration_date: line_item.back_from_alteration_date)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
