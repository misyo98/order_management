class LineItemStateTransition < ActiveRecord::Base
  belongs_to :line_item
  belongs_to :user, -> { with_deleted }
  belongs_to :courier, class_name: 'CourierCompany'
  belongs_to :tailor, class_name: 'AlterationTailor', foreign_key: :tailor_id

  after_create :update_item_entered_state_date

  delegate :first_name, :last_name, to: :user,            prefix: true, allow_nil: true
  delegate :name,                   to: :tailor,          prefix: true
  delegate :name,                   to: :courier,         prefix: true

  def self.last_event(event)
    @last_event = where(event: event).order(created_at: :asc).last

    @last_event.blank? ? nil : @last_event
  end

  def self.last_entered_state(state)
    @last_entered_state = where(to: state).order(created_at: :asc).last

    @last_entered_state.blank? ? nil : @last_entered_state
  end

  private

  def update_item_entered_state_date
    if event&.to_sym&.in?(LineItems::TriggerState::ALL_EVENTS)
      line_item.update_column(:state_entered_date, created_at)
    end
  end
end
