context.instance_eval do
  selectable_column unless current_user.tailor?
  id_column
  table_columns.each do |table_column|
    next if table_column.invisible || table_column.not_for_outfitters?(current_user)

    column(table_column.label, sortable: table_column.sortable_state, humanize_name: false) do |item|
      LineItemDecorator.decorate(item, context: { timelines: assigns[:timelines] }).public_send(table_column.name)
    end
  end
  actions defaults: false do |item|
    LineItemDecorator.decorate(item).allowed_state_event_links
  end
end
