class FabricBook < ActiveRecord::Base
  has_many :fabric_infos, -> { unscope(where: :deleted_at) }

  acts_as_paranoid

  validates :title, presence: true

  establish_connection(:remote_db) if !Rails.env.test?
end
