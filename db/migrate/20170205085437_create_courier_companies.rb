class CreateCourierCompanies < ActiveRecord::Migration
  def change
    create_table :courier_companies do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
