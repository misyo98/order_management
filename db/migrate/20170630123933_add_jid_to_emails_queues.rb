class AddJidToEmailsQueues < ActiveRecord::Migration
  def change
    add_column :emails_queues, :jid, :string, after: :status
  end
end
