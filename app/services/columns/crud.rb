module Columns
  class CRUD

    def initialize(params: {}, object: nil)
      @params = params
      @column = object if object
    end

    def update
      perform_update
    end

    def reorder
      new_columns = params[:columns]

      if params[:scope]
        old_columns = LineItemScope.includes(:columns).find_by(label: params[:scope].titleize).columns        
      else
        old_columns = column.class.public_send(params[:page])
      end

      perform_reordering(old_columns: old_columns, new_columns: new_columns)
    end

    def batch_update
      columns = column.class.where(id: params[:columns].keys)

      columns.each do |column|
        is_checked = is_column_checked?(id: column.id)
        column.update_attribute(:visible, is_checked)
      end
    end

    private

    attr_reader :params
    attr_accessor :column

    def perform_update
      checked = params[:checked] == 'true'
      column.update_attribute(:visible, checked)
    end

    def perform_reordering(old_columns:, new_columns:)
      old_columns.each do |column|
        next if new_columns[column.label] == column.order.to_s
        column.update_attribute(:order, new_columns[column.label])
      end
    end

    def is_column_checked?(id:)
      params[:columns][id.to_s] == 'true'
    end

    def scrape_columns
      params[:columns].inject({}) { |hash, column_hash|  hash[column_hash[0].underscore.gsub(' ', '_')] = column_hash[1]; hash }
    end
  end
end