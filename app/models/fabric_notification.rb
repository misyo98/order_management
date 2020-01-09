class FabricNotification < ActiveRecord::Base
  belongs_to :fabric_manager, primary_key: :manufacturer_fabric_code, foreign_key: :manufacturer_fabric_code

  enum event: %i(added updated removed)

  def fields_for_email
    "#{manufacturer_fabric_code} - #{fabric_brand_title} - #{fabric_book_title} - #{fabric_code}"
  end
end
