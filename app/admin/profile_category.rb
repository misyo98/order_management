ActiveAdmin.register ProfileCategory do
  menu false

  permit_params :status, :category_id, :customer_id

  member_action :history, method: :get

  controller do
    def update
      ProfileCategories::CRUD.new(
        profile_categories: {
          params[:id] => {
            status: params[:profile_category][:status]
          }
        },
        user_id: current_user.id
      ).update_states

      head :no_content
    end

    def history
      @profile_category = ProfileCategory.find_by(id: params[:id])
    end
  end
end
