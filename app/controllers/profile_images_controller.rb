class ProfileImagesController < ApplicationController
  respond_to :js

  def destroy
    @id = params[:id]
    @image = ProfileImage.find_by(id: params[:id])
    @image.destroy

    respond_with @image
  end
end
