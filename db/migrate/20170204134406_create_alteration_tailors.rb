class CreateAlterationTailors < ActiveRecord::Migration
  def change
    create_table :alteration_tailors do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
