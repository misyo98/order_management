class CreateEmailsQueues < ActiveRecord::Migration
  def change
    create_table  :emails_queues do |t|
      t.integer   :recipient_id
      t.string    :recipient_type
      t.integer   :subject_id
      t.string    :subject_type
      t.text      :options
      t.string    :tracking_number
      t.datetime  :sent_at
      t.integer   :status, default: 0
      t.datetime  :deleted_at

      t.index [:recipient_id, :recipient_type]
      t.index [:subject_id, :subject_type]
      t.index :deleted_at
      t.index :tracking_number

      t.timestamps null: false
    end
  end
end
