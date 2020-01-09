class InvoiceFile < ActiveRecord::Base
  mount_uploader :attachment, InvoiceAttachmentUploader
  belongs_to :invoice
end
