class AlterationInfosController < ApplicationController
  respond_to :html, :js
  def new
    @info = AlterationInfo.new(
      profile_id:  params[:profile_id], 
      category_id: params[:category_id],
      author_id:   current_user.id
      )

    respond_with @info
  end
end
