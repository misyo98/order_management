class MeasurementValidationDependency < ActiveRecord::Base
  belongs_to :depends_on, class_name: 'CategoryParam'
  belongs_to :dependant, class_name: 'CategoryParam'
end
