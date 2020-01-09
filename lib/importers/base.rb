module Importers
  class Base
    Result = Struct.new(:success?,:count,:error, :message)

    def initialize(file:, user_id: nil)
      @file = formatted_file(file)
      @user_id = user_id
      
      after_initialize
    end

    def call
      process
    rescue => error
      Rails.logger.error(error.message)
      result(success: false, error: error.message)
    end

    private

    attr_reader :file, :user_id

    def process
      raise NotImplementedError, 'Method process must be implemented'
    end

    def after_initialize
    end

    def result(success:, count: 0, error: nil, message: '')
      Result.new(success, count, error, message)
    end

    def scrape_attributes(line:, attributes_hash:)
      attributes = {}
      attributes_hash.each do |column, csv_pattern|
        attributes[column] = find_value(pattern: csv_pattern, line: line)
      end
      attributes
    end

    def find_value(pattern:, line:)
      line.find { |key, value| key.scan(pattern).any? }&.dig(1)
    end

    def formatted_file(file)
      data = File.read(file.path)
      filtered_data = data.gsub(",", ";")
      File.open(file.path, "w") do |f|
        f.write(filtered_data)
      end
      file
    end
  end
end
