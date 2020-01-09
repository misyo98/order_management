ActiveAdmin.register_page 'Detached Profile' do
  menu false

  content only: :index do
    render 'admin/customer/measurements_table', context: self, profile: profile

    h3 'Images'

    profile.images.each do |image|
      span class: 'inline-block', id: "profile-image-#{image.id}" do
        (link_to image_tag(image.image_url, height: '120'), image.image_url, class: :fancybox, rel: :group) +
        (link_to 'Delete image', profile_image_path(image.id), class: 'delete-image', remote: true, method: :delete, data: { confirm: 'Are you sure?' })
      end
    end
  end

  sidebar "Navigation", only: :index do
    if deleted_profiles.any?
      deleted_profiles.each do |profile|
        span link_to "Detached on #{ profile.deleted_at.strftime('%B %d, %Y %H:%M') }", detached_profile_path(profile_id: profile.id)
      end
    else
      'No other detached profiles yet'
    end
  end

  action_item :back_to_profile, only: :index do
    link_to 'Back to Customer', customer_path(id: profile.customer.id)
  end

  controller do
    def index
      @profile            = Profile.with_deleted.with_includes.find_by(id: params[:profile_id])
      @infos              = AlterationInfo.with_deleted.where(profile_id: params[:profile_id]).group_by(&:category_id)
      @category_params    = CategoryParam.all.includes(:category, :param).group_by(&:category_id)
      @deleted_profiles   = Profile.only_deleted.where(customer_id: @profile.customer_id).where.not(id: @profile.id)
      @comments           = ActiveAdmin::Comment.where(resource_type: 'Customer', resource_id: params[:id])
      @decorated_comments = CommentsDecorator.decorate(@comments)
      @comments           = @comments.group_by(&:category_id)
      @profile            = @profile.decorate
    end
  end
end
