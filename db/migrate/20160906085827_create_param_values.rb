class CreateParamValues < ActiveRecord::Migration
  def change
    create_table :param_values do |t|
      t.references :param
      t.references :value, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
