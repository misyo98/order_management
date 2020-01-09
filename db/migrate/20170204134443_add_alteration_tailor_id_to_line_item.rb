class AddAlterationTailorIdToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :alteration_tailor_id, :integer, after: :next_appointment_date
  end
end
