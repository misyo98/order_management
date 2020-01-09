class CreateCostBuckets < ActiveRecord::Migration
  def change
    create_table :cost_buckets do |t|
      t.string :label

      t.timestamps null: false
    end
  end
end
