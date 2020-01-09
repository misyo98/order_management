class AddCostBucketToRealCog < ActiveRecord::Migration
  def change
    add_column :real_cogs, :cost_bucket, :integer, after: :cogs_rc_usd
  end
end
