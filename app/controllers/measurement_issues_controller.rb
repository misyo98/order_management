class MeasurementIssuesController < ApplicationController
  before_action :find_issuable, only: :new
  load_resource through: :issueable, only: :new
  load_resource only: [:create, :edit, :update]

  def new
  end

  def create
    @measurement_issue.save
    @issueable = @measurement_issue.issueable
  end

  def edit
    @issueable = @measurement_issue.issueable
  end

  def update
    @issueable = @measurement_issue.issueable
    @measurement_issue.update(measurement_issue_params)
  end

  def destroy
    @measurement_issue = MeasurementIssue.find(params[:id])
    @measurement_issue.destroy

    render nothing: true
  end

  private

  def find_issuable
    @issueable = params[:issueable_type].safe_constantize.find_by(id: params[:issueable_id])
  end

  def measurement_issue_params
    params.require(:measurement_issue).permit(
      :issue_subject_id,
      :fixed,
      :issueable_type,
      :issueable_id,
      messages_attributes: %i(id _destroy author_id body)
    )
  end
end
