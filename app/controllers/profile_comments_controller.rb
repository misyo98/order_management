class ProfileCommentsController < ApplicationController
  def create
    Comments::CRUD.new(params: comment_params).create
    
    redirect_to customer_path(id: params[:active_admin_comment][:resource_id])
  end

  private

  def comment_params
    params.require(:active_admin_comment)
          .permit(:body, :namespace, :resource_id, :category_id, :category_ids,
                  :resource_type, :author_id, :author_type, :submission)
  end
end
