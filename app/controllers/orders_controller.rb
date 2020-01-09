class OrdersController < ApplicationController
  respond_to :js, :json

  def show
    @order = Order.includes(:line_items).find_by(id: params[:id])
    @category_params = CategoryParam.all.includes(:category, :param).order(:order).group_by(&:category_id)
    @comments = ActiveAdmin::Comment.where(resource_type: 'Customer', resource_id: @order.customer_id)
                                    .select(:body, :category_id).reject {|comment| comment.body.blank? }
                                    .group_by(&:category_id)
    @alteration_comments = AlterationInfo.select(:comment, :category_id).where(profile_id: @order.customer&.profile_id)
                                         .reject {|info| info.comment.blank? }.group_by(&:category_id)

    respond_with @order
  end

  def update
    @order = Order.find_by(id: params[:id])
    @order.update(order_params)

    respond_with @order
  end

  private

  def order_params
    params.require(:order).permit(:comment).merge!(submitter_id: current_user.id)
  end
end
