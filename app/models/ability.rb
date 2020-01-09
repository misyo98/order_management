class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new

    alias_action :create, :read, :update, :destroy, to: :crud

    case
    when user.admin?
      can :manage, :all
      cannot :destroy, Invoice, status: Invoice.statuses[:paid]
      cannot :measurements_csv_filters, Customer unless user.can_download_measurements_csv
      cannot :manage, FabricTierCategory
      cannot :manage, EnabledFabricCategory
    when user.phone_support?
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can :read, ActiveAdmin::Page, name: 'Appoitment List'
    when user.outfitter?
      can :manage, :all
      cannot :review, Measurement
      cannot :edit, Allowance
      cannot :see_details, Customer
      cannot :crud, User
      cannot :crud, ProfileCategory
      cannot :edit_state, LineItem
      cannot :edit_sales_person, LineItem
      cannot :import_states, LineItem
      cannot :update_meta, LineItem
      cannot :manage_columns, Column
      cannot :index, Accounting
      cannot :crud, CostBucket
      cannot :crud, CourierCompany
      cannot :crud, EstimatedCog
      cannot :crud, FabricInfo
      cannot :crud, FxRate
      cannot :crud, RealCog
      cannot :crud, SalesLocation
      cannot :crud, VatRate
      cannot :crud, AlterationTailor
      cannot :crud, AlterationService
      cannot :crud, LineItemScope
      cannot :crud, StatesTimeline
      cannot %i[create update destroy], FittingGarment
      can :read, FittingGarment
      cannot %i[create update destroy], CategoryParam
      can :read, CategoryParam
      cannot %i[create update destroy], IssueSubject
      can :read, IssueSubject
      cannot %i[create update destroy], MeasurementCheck
      can :read, MeasurementCheck
      cannot :send, EmailsQueue
      cannot :deduct_sales_person, LineItem
      cannot :deduct_ops_person, LineItem
      cannot :not_updated, AlterationSummary
      cannot :manage, Refund
      cannot :manage, RefundReason
      cannot %i[create update destroy], Tag
      can :read, Tag
      cannot :manage, FabricTier
      cannot :manage, FabricTierCategory
      cannot :manage, EnabledFabricCategory
      cannot :manage, FabricManager
      can :read, FabricInfo
      cannot :import, FabricInfo
      cannot :archived, FabricInfo
      cannot :fabrics_csv, FabricInfo
    when user.senior_outfitter?
      can :manage, :all
      cannot :destroy, Invoice, status: Invoice.statuses[:paid]
      cannot :measurements_csv_filters, Customer
      cannot :import, FabricInfo
      cannot :fabrics_csv, FabricInfo
      cannot :download_csv, :all
      cannot :manage, AlterationService
      cannot :manage, AlterationTailor
      cannot :manage, CourierCompany
      cannot :manage, MeasurementIssue
      cannot :manage, Queue
      cannot :manage, RefundReason
      cannot :manage, SalesLocation
      cannot :manage, StatesTimeline
      cannot :manage, Tag
      cannot :manage, LineItemScope
      cannot :manage, CostBucket
      cannot :manage, EstimatedCog
      cannot :manage, FxRate
      cannot :manage, RealCog
      cannot :manage, Refund
      cannot :manage, VatRate
      cannot :manage, DropdownList
      cannot :manage, EnabledFabricCategory
      cannot :manage, FabricBook
      cannot :manage, FabricBrand
      cannot :manage, FabricInfo
      cannot :manage, FabricManager
      cannot :manage, FabricTab
      cannot :manage, FabricOption
      cannot :manage, FabricOptionValue
      cannot :manage, FabricTier
      cannot :manage, FabricTierCategory
      cannot :manage, FittingGarment
      cannot :manage, Accounting
      cannot [:update, :destroy], User
      cannot :read, ActiveAdmin::Page, name: 'Accounting'
      cannot :read, ActiveAdmin::Page, name: 'Dropdown List Values'
      cannot :read, ActiveAdmin::Page, name: 'Issues'
      cannot :read, ActiveAdmin::Page, name: 'State in queue check'
      cannot :read, ActiveAdmin::Page, name: 'Remaining COGS'
    when user.ops?
      can :manage, :all
      cannot :crud, Allowance
      cannot :crud, Customer
      cannot :crud, User
      cannot :crud, ProfileCategory
      cannot :manage_columns, Column
      cannot :crud, StatesTimeline
      cannot :crud, Accounting
      cannot :crud, CostBucket
      cannot :crud, EstimatedCog
      cannot :crud, FxRate
      cannot :crud, RealCog
      cannot :crud, VatRate
      cannot :crud, AlterationService
      cannot :crud, AlterationTailor
      cannot :crud, CourierCompany
      cannot :crud, FabricInfo
      cannot :crud, SalesLocation
      cannot :crud, StatesTimeline
      cannot :crud, LineItemScope
      cannot :download_csv, :all
      cannot :edit_sales_person, LineItem
      cannot :import_states, LineItem
      cannot :deduct_sales_person, LineItem
      cannot :deduct_ops_person, LineItem
      cannot [:destroy, :create], LineItem
      cannot :edit, Customer
      can :save_adjustments, Customer
      can :add_new_measurement, Customer
      can :call, Customer
      can :review, Measurement
      can :shipment_numbers, LineItem
      can :import_link, LineItem
      can :update_meta, LineItem
      can :download_csv_being_altered, LineItem
      can :download_csv_alteration_requests, LineItem
      can :download_csv_shipment_preparation, LineItem
      can :download_csv_at_office_waiting, LineItem
      can :download_csv_at_office_decision_required, LineItem
      can :download_csv_delivery_mail_sent, LineItem
      can :download_csv_delivery_arranged, LineItem
      cannot :manage, Refund
      cannot :manage, RefundReason
      cannot :manage, Tag
      cannot :manage, FabricTier
      cannot :manage, FabricTierCategory
      cannot :manage, EnabledFabricCategory
      can :read, FabricInfo
      cannot :import, FabricInfo
      cannot :archived, FabricInfo
      cannot :fabrics_csv, FabricInfo
    when user.suit_placing?
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can [:read, :update], LineItem
      cannot :crud, User
      cannot :update_meta, LineItem
      cannot :edit, Customer
      can :read_meta, LineItem
      can :read, Customer
      can :add_new_measurement, Customer
      can :save_adjustments, Customer
      can :read, CustomerDecorator
      can :review, Measurement
      cannot :manage, Refund
      cannot :manage, RefundReason
      cannot :manage, FabricTierCategory
      cannot :manage, EnabledFabricCategory
      can :read, FabricInfo
      cannot :import, FabricInfo
      cannot :archived, FabricInfo
      cannot :fabrics_csv, FabricInfo
    when user.tailor?
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can :read, LineItem if user.inhouse?
      can :crud, AlterationSummary
      can [:create,:read], Invoice
      can [:update, :destroy], Invoice, status: Invoice.statuses[:invoiced]
      can :download_csv, AlterationSummary
      can :destroy, AlterationService, author_id: user.id
      cannot :manage, FabricTierCategory
      cannot :manage, EnabledFabricCategory
    end
  end
end
