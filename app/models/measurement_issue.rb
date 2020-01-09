class MeasurementIssue < ActiveRecord::Base
  belongs_to :issueable, polymorphic: true
  belongs_to :issue_subject
  belongs_to :measurement, -> { includes(:measurement_issues).where(measurement_issues: { issueable_type: 'Measurement' }) },
                          foreign_key: :issueable_id
  belongs_to :profile, -> { includes(:measurement_issues).where(measurement_issues: { issueable_type: 'Profile' }) },
                          foreign_key: :issueable_id

  has_many :messages, class_name: 'MesurementIssueMessage', dependent: :destroy

  validates :issue_subject, presence: true

  accepts_nested_attributes_for :messages, allow_destroy: true

  scope :for_measurements, -> { where(issueable_type: 'Measurement') }
end
