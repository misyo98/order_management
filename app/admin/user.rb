ActiveAdmin.register User do
  before_filter :right_sidebar!
  menu priority: 13, if: -> { can? :edit, User }
  actions :all

  action_item :login, only: :show do
    link_to 'Login as User', login_user_path(user), method: :post if current_user.admin?
  end

  member_action :login, method: :post
  collection_action :to_be_fixed_profiles, method: :get

  permit_params :email, :password, :password_confirmation, :role, :first_name, :last_name, :id, :country,
                :can_submit_measurements, :can_review_measurements, :alteration_tailor_id, :inhouse,
                :can_send_delivery_emails, :receive_all_alteration_emails, :receive_validation_violations_emails,
                :can_download_measurements_csv, sales_location_ids: []

  index download_links: -> { can?(:download_csv, User) } do
    selectable_column
    id_column if can? :crud, User
    column :first_name
    column :last_name
    column :email
    column :country
    column(:sales_locations) { |user| user.sales_locations.map(&:name).join(', ') }
    column :auth_token if can? :edit, User
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions if can? :crud, User
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :first_name
      f.input :last_name
      if f.object.new_record?
        f.input :password
        f.input :password_confirmation
      end
      f.input :role
      f.input :receive_all_alteration_emails if current_user.admin?
      f.input :can_send_delivery_emails, wrapper_html: { class: !f.object.outfitter? && 'hidden' }
      f.input :alteration_tailor, wrapper_html: { class: !f.object.tailor? ? 'hidden' : '' }
      f.input :inhouse, wrapper_html: { class: !f.object.tailor? ? 'hidden' : '' }
      f.input :sales_locations, label: 'Restrict items and queues to', include_blank: true, input_html: { size: 10, style: 'height: 100%;' }
      f.input :country, as: :select, collection: LineItem::COUNTRY_TO_CURRENCY.keys
      f.input :can_review_measurements, label: 'Can submit profiles with errors' if current_user.admin?
      f.input :can_submit_measurements, label: 'Can submit profiles without errors' if current_user.admin?
      f.input :receive_validation_violations_emails if current_user.admin?
      f.input :can_download_measurements_csv, input_html: { disabled: true } if current_user.admin?
    end
    f.actions
  end

  controller do
    def login
      user = User.find(params[:id])
      bypass_sign_in user
      redirect_to root_path
    end

    def to_be_fixed_profiles
      @to_be_fixed_profile_categories = current_user.created_profile_categories.to_be_fixed.uniq.group_by(&:profile)

      render 'admin/user/to_be_fixed_profiles'
    end

    def scoped_collection
      super.includes(:sales_locations)
    end
  end
end
