module Admin
  class Summary < Struct.new(
    :category_param, :adjustment_increase, :adjustment_increase_ids,
    :adjustment_decrease, :adjustment_decrease_ids,
    :alter_increase, :alter_increase_ids,
    :alter_decrease, :alter_decrease_ids,
    :alter_total, :alter_total_ids,
    :total_submissions, :total_submissions_ids,
    :alter_percentage
  )

    def initialize(*)
      super
      self.adjustment_increase     ||= 0
      self.adjustment_increase_ids ||= []
      self.adjustment_decrease     ||= 0
      self.adjustment_decrease_ids ||= []
      self.alter_increase          ||= 0
      self.alter_increase_ids      ||= []
      self.alter_decrease          ||= 0
      self.alter_decrease_ids      ||= []
      self.alter_total             ||= 0
      self.alter_total_ids         ||= []
      self.alter_percentage        ||= 0
      self.total_submissions_ids   ||= []
      self.total_submissions       ||= 0
    end
  end
end
