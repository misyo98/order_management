module Exporters
  class Base
    Result = Struct.new(:success?,:count,:error, :message)

    def initialize(records:, table_columns: nil, options: {})
      @records = records
      @table_columns = table_columns
      @options = options

      after_initialize
    end

    def call
      process
    rescue => error
      Rails.logger.error(error.message)
      result(success: false, error: error.message)
    end

    private

    attr_reader :records, :table_columns, :options

    def process
      raise NotImplementedError, 'Method process must be implemented'
    end

    def after_initialize
    end

    def result(success:, count: 0, error: nil, message: '')
      Result.new(success, count, error, message)
    end
  end
end
