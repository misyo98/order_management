# frozen_string_literal: true

module ApplicationHelper
  COUNTRIES_FOR_SELECT = %w(SG GB Other).freeze
  EMPTY_VALUE = [nil, 'None'].freeze
  YES = 'YES'
  NO = 'NO'

  def reviewable?(review_action:)
    can?(:review, Measurement) && review_action
  end

  def self.sales_persons_collection
    User.with_deleted.pluck(:id, :first_name, :last_name)
        .map { |person| [person[0], "#{person[1]} #{person[2]}"] }
  end

  def self.sales_locations_collection
    SalesLocation.pluck(:id, :name)
  end

  def self.tailors_collection
    AlterationTailor.pluck(:id, :name)
  end

  def self.couriers_collection
    CourierCompany.pluck(:id, :name)
  end

  def self.cost_buckets_collection
    CostBucket.pluck(:id, :label)
              .insert(0, EMPTY_VALUE)
  end

  def self.timelines_collection
    StatesTimeline.includes(:sales_location_timelines).all
  end

  def self.ops_collection
    User.with_deleted.ops_people.pluck(:id, :first_name, :last_name)
        .map { |person| [person[0], "#{person[1]} #{person[2]}"] }
  end

  def fitting_garment_collection(category_id = nil)
    if category_id
      FittingGarment.order(order: :asc).where(country: [current_user.country, nil], category_id: category_id).pluck(:name, :id)
    else
      FittingGarment.order(order: :asc).where(country: [current_user.country, nil]).pluck(:name, :id)
    end
  end

  def accounting_access?
    can?(:index, Accounting) || can?(:index, CostBucket) ||
    can?(:index, EstimatedCog) || can?(:index, FxRate) || can?(:index, RealCog) ||
    can?(:index, RealCog) || can?(:index, VatRate)
  end

  def settings_access?
    can?(:index, AlterationService) || can?(:index, AlterationTailor) ||
    can?(:index, CourierCompany) || can?(:index, EstimatedCog) ||
    can?(:index, LineItemScope) || can?(:index, SalesLocation) ||
    can?(:index, StatesTimeline) || can?(:index, MeasurementIssue)
  end

  def alteration_access?
    can?(:read, AlterationSummary) || can?(:not_updated, AlterationSummary)
  end

  def appointment_access?
    !current_user.suit_placing? && !current_user.tailor?
  end

  def to_yes_or_no_string(boolean)
    boolean ? YES : NO
  end
end
