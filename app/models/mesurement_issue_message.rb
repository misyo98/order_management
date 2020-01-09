class MesurementIssueMessage < ActiveRecord::Base
  belongs_to :measurement_issue
  belongs_to :author, class_name: 'User'
end
