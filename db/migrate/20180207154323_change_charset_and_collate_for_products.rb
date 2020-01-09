class ChangeCharsetAndCollateForProducts < ActiveRecord::Migration
  def change
    execute "ALTER TABLE products CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
  end
end
