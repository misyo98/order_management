class UserSalesLocation < ActiveRecord::Base
  belongs_to :user
  belongs_to :sales_location
end
