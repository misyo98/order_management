class AddCourierCompanyIdToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :courier_company_id, :integer, after: :alteration_tailor_id
  end
end
