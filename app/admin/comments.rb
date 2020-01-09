module ActiveAdmin

  Comment.class_eval do
    acts_as_paranoid

    belongs_to :updater, class_name: 'User'
    belongs_to :author, -> { with_deleted }, class_name: 'User'
    belongs_to :category
    # belongs_to :customer, foreign_key: :resource_id, foreign_type: :resource_type

    delegate :full_name, to: :updater, prefix: true, allow_nil: true
    delegate :full_name, to: :author, prefix: true, allow_nil: true

    def self.submitted
      where(submission: true)
    end

    def self.unsubmitted
      where(submission: false)
    end
  end

end
