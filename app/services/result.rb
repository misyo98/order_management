class Result
  attr_accessor :errors, :data

  def initialize
    @errors = []
    @data = {}
  end

  def success?
    errors.empty?
  end
end
