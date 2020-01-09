class SetOrder
  TABLES = {
    fabric_book: FabricBook,
    fabric_brand: FabricBrand
  }.freeze

  def self.call(*args)
    new(*args).call
  end

  def initialize(items:, table_name:)
    @items = items
    @table_name = TABLES[table_name]
  end

  def call
    return if table_name.nil?

    items.each_with_index do |id, index|
      item = table_name.find(id)

      item.update_column(:order, index + 1) if item
    end
  end

  private

  attr_reader :items, :table_name
end
