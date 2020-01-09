class CreateRefundReasons < ActiveRecord::Migration
  REASONS = ['Made - Wrong fabric', 'Made - Wrong customisation', 'Made - Missed deadline',
             'Made - Customer not satisfied', 'Made - Lost item', 'Made - Discount not applied during checkout',
             'Not made - Fabric OOS', 'Not made - Customer cancelled', 'Not made - Can’t meet deadline', 'Other']

  def change
    create_table :refund_reasons do |t|
      t.string :title

      t.timestamps null: false
    end

    RefundReason.reset_column_information

    REASONS.each do |reason|
      RefundReason.create!(title: reason)
    end
  end
end
