class ProfileImage < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  belongs_to :profile
end
