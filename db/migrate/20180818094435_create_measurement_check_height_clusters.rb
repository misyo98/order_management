class CreateMeasurementCheckHeightClusters < ActiveRecord::Migration
  def up
    create_table :measurement_check_height_clusters do |t|
      t.references :measurement_check, index: true, foreign_key: true
      t.decimal :upper_limit, precision: 10, scale: 2
      t.decimal :min, precision: 10, scale: 2
      t.decimal :max, precision: 10, scale: 2

      t.timestamps null: false
    end
  end

  def down
    drop_table :measurement_check_height_clusters
  end
end
