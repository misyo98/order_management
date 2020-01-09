class AddPaymentRequiredToAlterationSummaries < ActiveRecord::Migration
  def change
    add_column :alteration_summaries, :payment_required, :boolean, default: false, after: :urgent
  end
end
