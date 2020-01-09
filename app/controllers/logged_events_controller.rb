class LoggedEventsController < ApplicationController
  def index
    line_item = LineItem.includes(:logged_events, :versions).find_by(id: params[:line_item_id])
    @events = LoggedEvents::CRUD::Index.(line_item)
  end
end
