class ColumnsController < ApplicationController
  respond_to :js

  def update
    Columns::CRUD.new(params: params, object: Column.find_by(id: params[:id])).update
    head :ok
  end

  def reorder
    Columns::CRUD.new(params: params, object: Column.new).reorder
    head :ok
  end

  def batch_update
    Columns::CRUD.new(params: params, object: Column.new).batch_update
    head :ok
  end
end
