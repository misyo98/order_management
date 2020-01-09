class AddLastEmailSentDateToColumns < ActiveRecord::Migration
  def up
    column_params = { name: 'last_email_sent_date', label: 'Last Email Sent Date', order: 59 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'last_email_sent_date').delete_all
  end
end
