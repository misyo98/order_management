class CategoriesController < ApplicationController
  respond_to :html, :json, :js

  def index
    @categories = Category.all.order(:order)
  end
end
