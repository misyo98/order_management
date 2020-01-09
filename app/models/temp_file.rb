class TempFile < ActiveRecord::Base
  mount_uploader :attachment, TempFileUploader
end
