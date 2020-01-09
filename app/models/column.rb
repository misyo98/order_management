class Column < ActiveRecord::Base

  belongs_to :columnable, polymorphic: true

  scope :visible, -> { where(visible: true) }

  scope :line_items, -> { where(columnable_type: 'LineItem') }

  scope :accounting, -> { where(columnable_type: 'Accounting') }

  scope :remaining_cogs, -> { where(columnable_type: 'RemainingCogs') }

end
