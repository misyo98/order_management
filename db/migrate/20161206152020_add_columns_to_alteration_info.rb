class AddColumnsToAlterationInfo < ActiveRecord::Migration
  def change
    change_table :alteration_infos do |t|
      t.column :lapel_flaring, :text, after: :comment
      t.column :shoulder_fix, :text, after: :lapel_flaring
      t.column :move_button, :text, after: :shoulder_fix
      t.column :square_back_neck, :text, after: :move_button
      t.column :armhole, :text, after: :square_back_neck
    end
  end
end
