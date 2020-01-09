class CreateSentTrackingNumbers < ActiveRecord::Migration
  def change
    create_table :sent_tracking_numbers do |t|
      t.string :number

      t.timestamps null: false
    end
  end
end
