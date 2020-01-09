module LineItems
  class CreateMeta
    Result = Struct.new(:success?, :error_messages)

    def self.call(*attrs)
      new(*attrs).call
    end

    def initialize(line_item, params)
      @params = params
      @line_item = line_item
      @validator = MetasValidator.new(params)
      @errors = []
    end

    def call
      if validator.valid?
        meta_hash = { 'key' => params[:label], 'label' => params[:label], 'value' => params[:value] }
        line_item.meta << meta_hash

        if line_item.save
          result(true)
        else
          result(false, line_item.errors.full_messages)
        end
      else
        result(false, validator.error_messages)
      end
    end

    private

    attr_reader :line_item, :params, :validator
    attr_accessor :errors

    def result(success, messages = [])
      Result.new(success, messages)
    end
  end
end
