class AlterationImage < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  
  belongs_to :alteration_summary
end
