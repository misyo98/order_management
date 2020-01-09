class AddDeductionColumnsToOrderTable < ActiveRecord::Migration
  COLUMNS_PARAMS = [
    { name: 'deduction_sales_amount', label: 'Deduction Sales to deduct from', order: 64 },
    { name: 'deduction_sales_person_field', label: 'Sales person to deduct from', order: 65 },
    { name: 'deduction_sales_comment_field', label: 'Comment - Sales Deduction', order: 66 },
    { name: 'deduction_ops_amount', label: 'Deduction Ops to deduct from', order: 67 },
    { name: 'deduction_ops_person_field', label: 'Ops person to deduct from', order: 68 },
    { name: 'deduction_ops_comment_field', label: 'Comment - Ops Deduction', order: 69 },
  ].freeze

  def up
    add_column :line_items, :deduction_sales, :decimal, precision:8, scale: 2
    add_column :line_items, :deduction_sales_person_id, :integer
    add_column :line_items, :deduction_sales_comment, :string
    add_column :line_items, :deduction_ops, :decimal, precision:8, scale: 2
    add_column :line_items, :deduction_ops_person_id, :integer
    add_column :line_items, :deduction_ops_comment, :string

    add_index :line_items, :deduction_sales_person_id
    add_index :line_items, :deduction_ops_person_id

    LineItemScope.find_each do |scope|
      COLUMNS_PARAMS.each { |column_params| scope.columns.create!(column_params) }
    end
  end

  def down
    remove_column :line_items, :deduction_sales if column_exists? :line_items, :deduction_sales
    remove_column :line_items, :deduction_sales_person_id if column_exists? :line_items, :deduction_sales_person_id
    remove_column :line_items, :deduction_sales_comment if column_exists? :line_items, :deduction_sales_comment
    remove_column :line_items, :deduction_ops if column_exists? :line_items, :deduction_ops
    remove_column :line_items, :deduction_ops_person_id if column_exists? :line_items, :deduction_ops_person_id
    remove_column :line_items, :deduction_ops_comment if column_exists? :line_items, :deduction_ops_comment

    column_names = COLUMNS_PARAMS.inject([]) { |names, column_params| names << column_params[:name] }

    Column.where(columnable_type: 'LineItemScope', name: column_names).delete_all
  end
end
