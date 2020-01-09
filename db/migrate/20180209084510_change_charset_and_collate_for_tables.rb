class ChangeCharsetAndCollateForTables < ActiveRecord::Migration
  def change
    execute "ALTER TABLE alteration_service_tailors CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE alteration_services CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE alteration_summary_line_items CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE alteration_summary_services CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE alteration_tailors CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE columns CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE cost_buckets CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE courier_companies CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE emails_queues CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE estimated_cogs CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE fabric_infos CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE fx_rates CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE line_item_scopes CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE line_item_state_transitions CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE order_columns CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE products_categories CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE profile_categories CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE real_cogs CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE sales_locations CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE scope_order_columns CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE sent_tracking_numbers CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE sessions CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE states_timelines CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
    execute "ALTER TABLE vat_rates CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
  end
end