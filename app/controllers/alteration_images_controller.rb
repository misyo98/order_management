class AlterationImagesController < ApplicationController
  respond_to :js

  def index
    @images = AlterationImage.where(alteration_summary_id: params[:alteration_summary_id])
  end
  
  def destroy
    @image = AlterationImage.find(params[:id])
    @image.destroy

    respond_with @image
  end
end
