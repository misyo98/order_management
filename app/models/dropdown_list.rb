class DropdownList < ActiveRecord::Base
  has_many :fabric_option_values

  establish_connection(:remote_db) if !Rails.env.test?
end
