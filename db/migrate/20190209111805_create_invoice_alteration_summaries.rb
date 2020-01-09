class CreateInvoiceAlterationSummaries < ActiveRecord::Migration
  def change
    create_table :invoice_alteration_summaries do |t|
      t.references :invoice, index: true, foreign_key: { on_cascade: :delete }
      t.references :alteration_summary, index: true, foreign_key: { on_cascade: :delete }

      t.timestamps null: false
    end
  end
end
