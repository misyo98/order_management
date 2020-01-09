class EnabledFabricCategory < ActiveRecord::Base
  belongs_to :fabric_info
  belongs_to :fabric_category

  establish_connection(:remote_db) if !Rails.env.test?
end
