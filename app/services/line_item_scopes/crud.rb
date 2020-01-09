module LineItemScopes
  class CRUD
    def initialize(params: {})
      @params = params
      @success = false
    end

    def create
      scope = LineItemScope.new(permitted_params)
      if scope.save
        @success = true
        create_order_columns(scope: scope)
      end
      scope
    end

    def success?
      success
    end

    private

    attr_reader :params
    attr_accessor :success

    def permitted_params
      params.require(:line_item_scope).permit(:label, { states: [], visible_for: [] }, :order, :show_counter, :include_unassigned_items,
                                              user_sales_location_ids: [], item_sales_location_ids: [])
    end

    def create_order_columns(scope:)
      raw_attributes = Column.line_items.pluck(:name, :order, :visible, :label)
      formatted_attributes = raw_attributes.inject([]) { |array, attributes|array << assign_column_attributes(attributes: attributes, scope_id: scope.id); array }

      scope_columns = formatted_attributes.inject([]) { |array, attributes| array << Column.new(attributes); array }

      Column.import scope_columns
    end

    def assign_column_attributes(attributes:, scope_id:)
      columns = %i(name order visible label)
      attributes = [columns, attributes].transpose.to_h
      attributes.merge!(columnable_id: scope_id, columnable_type: 'LineItemScope')
    end
  end
end
