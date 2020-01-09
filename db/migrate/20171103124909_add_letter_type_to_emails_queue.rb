class AddLetterTypeToEmailsQueue < ActiveRecord::Migration
  def up
    add_column :emails_queues, :letter_type, :integer, default: 0, after: :subject_type

    EmailsQueue.find_each do |email|
      email.update_column(:letter_type, EmailsQueue.letter_types[email.options[:type]])
    end
  end

  def down
    remove_column :emails_queues, :letter_type
  end
end
