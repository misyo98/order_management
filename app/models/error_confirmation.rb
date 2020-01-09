class ErrorConfirmation < ActiveRecord::Base
  belongs_to :measurement, inverse_of: :error_confirmation
end
