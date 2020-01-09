class CreateErrorConfirmations < ActiveRecord::Migration
  def change
    create_table :error_confirmations do |t|
      t.references :measurement, index: true, foreign_key: true
      t.boolean :confirmed

      t.timestamps null: false
    end
  end
end
