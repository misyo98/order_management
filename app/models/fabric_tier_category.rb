class FabricTierCategory < ActiveRecord::Base
  CURRENCIES = ['GBP', 'SGD'].freeze

  belongs_to :fabric_tier
  belongs_to :fabric_category

  attribute :price, ActiveRecord::Type::Json.new

  establish_connection(:remote_db) if !Rails.env.test?
end
