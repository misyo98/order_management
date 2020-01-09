class User < ActiveRecord::Base
  GREAT_BRITAIN = 'GB'.freeze
  SINGAPORE = 'SG'.freeze
  WHITELISTED_COUNTRIES = %w[gb sg].freeze
  SCOPES_FOR_TAILORS = %w(alteration_requests being_altered).freeze
  LIMITED_FABRICS_ACCESS = %w[outfitter ops suit_placing senior_outfitter].freeze
  RECEIVE_NOT_SENT_EMAILS_WARNING = %w(care_uk@editsuits.com care_sg@editsuits.com reto@editsuits.com jeroen@editsuits.com).freeze

  acts_as_paranoid

  devise :database_authenticatable, :recoverable, :rememberable,
         :trackable, :validatable, :timeoutable # :registerable

  enum role: %i(outfitter admin ops suit_placing tailor senior_outfitter phone_support)

  has_many :created_profiles, foreign_key: :author_id, class_name: 'Profile'
  has_many :created_profile_categories, foreign_key: :author_id, class_name: 'ProfileCategory'
  has_many :user_sales_locations
  has_many :sales_locations, through: :user_sales_locations
  # optional association for User with role "tailor"
  belongs_to :alteration_tailor

  validates :alteration_tailor_id, presence: true, if: proc { |u| u.tailor? }

  delegate :can?, :cannot?, to: :ability

  before_create :set_auth_token
  before_save :unassign_alteration_tailor

  scope :sales_people, -> { where(role: roles[:outfitter]) }
  scope :ops_people, -> { where(role: roles[:ops]) }
  scope :appointments_people, -> (country) {
    where(role: [roles[:admin], roles[:outfitter], roles[:ops]])
    .where(country: country)
  }
  scope :sales_people_with_country, -> (country) do
    where(role: [roles[:admin], roles[:outfitter], roles[:senior_outfitter]]).where(country: country)
  end
  scope :available_for_violation_emails, -> {
    where(
      arel_table[:receive_all_alteration_emails].eq(true)
      .and(arel_table[:receive_validation_violations_emails].eq(true))
      .or(arel_table[:receive_validation_violations_emails].eq(true))
    ).distinct
  }
  scope :available_for_regular_emails, -> {
    where(arel_table[:receive_all_alteration_emails].eq(true))
  }

  def ability
    @ability ||= Ability.new(self)
  end

  def set_auth_token
    return if auth_token.present?
    self.auth_token = generate_auth_token
  end

  def unassign_alteration_tailor
    self.alteration_tailor_id = nil unless tailor?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.outfitter?(id)
    find_by(id: id)&.outfitter?
  end

  def self.can_send_delivery_emails?(id)
    user = find_by(id: id)
    return true unless user
    user.can_send_delivery_emails?
  end

  def self.look_by_fullname(first_name, last_name)
    find_by(arel_table[:first_name].matches("%#{first_name}%").and(arel_table[:last_name].matches("%#{last_name}%")))
  end

  def timeout_in
    return 30.minutes if outfitter?
    30.days
  end

  def gb_user?
    country == GREAT_BRITAIN
  end

  def sg_user?
    country == SINGAPORE
  end

  def limited_fabrics_access?
    role.in?(LIMITED_FABRICS_ACCESS)
  end

  private

  def generate_auth_token
    SecureRandom.uuid.gsub(/\-/,'')
  end
end
