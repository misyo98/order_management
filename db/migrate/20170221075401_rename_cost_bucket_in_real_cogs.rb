class RenameCostBucketInRealCogs < ActiveRecord::Migration
  def change
    rename_column :real_cogs, :cost_bucket, :cost_bucket_id
  end
end
