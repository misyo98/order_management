context.instance_eval do
  column :id
  table_columns.each do |table_column|
    next unless table_column.visible

    column(table_column.label, sortable: table_column.sorting_scope, humanize_name: false) { |item| AccountingDecorator.decorate(item).public_send(table_column.name) }
  end
end
