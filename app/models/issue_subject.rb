class IssueSubject < ActiveRecord::Base
  validates :title, presence: true
end
