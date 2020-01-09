module LineItems
  class DestroyMeta
    def self.call(*attrs)
      new(*attrs).call
    end

    def initialize(line_item, params)
      @params = params
      @line_item = line_item
      @label = params[:label]
      @value = params[:value]
    end

    def call
      return unless label && value

      line_item.meta =
        line_item.meta.delete_if do |meta_hash|
          meta_hash['label'] == label && meta_hash['value'] == value
        end

      line_item.save
      line_item
    end

    private

    attr_reader :line_item, :label, :params, :value
  end
end
