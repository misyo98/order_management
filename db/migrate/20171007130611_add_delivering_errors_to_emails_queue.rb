class AddDeliveringErrorsToEmailsQueue < ActiveRecord::Migration
  def change
    add_column :emails_queues, :delivering_errors, :text, after: :jid
  end
end
