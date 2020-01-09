module MeasurementIssues
  class MesurementIssueMessagesController < ApplicationController
    respond_to :js

    load_resource :measurement_issue
    load_resource through: :measurement_issue, through_association: :messages

    def index
      @mesurement_issue_messages = @mesurement_issue_messages.includes(:author)
    end
  end
end
