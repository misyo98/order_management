module LineItems
  class UpdateTags

    def self.call(*attrs)
      new(*attrs).call
    end

    def initialize(line_item, tag_params)
      @tag_params = tag_params.blank? ? [] : tag_params
      @line_item = line_item
    end

    def call
      tag_ids =
        tag_params.each_with_object([]) do |tag_name, tag_ids|
          tag_ids << Tag.find_or_create_by(name: tag_name).id
        end
      line_item.update(tag_ids: tag_ids)
    end

    private

    attr_reader :line_item, :tag_params
  end
end
