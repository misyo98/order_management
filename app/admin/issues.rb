ActiveAdmin.register_page 'Issues' do
  menu parent: 'Settings', if: -> { can? :index, MeasurementIssue }

  content do
    div class: 'sidebar_section panel', id: 'filters_sidebar_section' do
      render "admin/issues/filters"
    end

    paginated_collection(issues, download_links: -> { can?(:download_csv, MeasurementIssue) }) do
      table_for(collection, sortable: true, class: 'index_table index', id: 'index_table_issues') do
        column(:customer_id, sortable: 'measurement_profile_customer_id') do |issue|
          customer_id = MeasurementIssueDecorator.decorate(issue).customer_id
          link_to customer_id, customer_path(customer_id)
        end
        column(:customer_name) { |issue| MeasurementIssueDecorator.decorate(issue).customer_name }
        column :created_at
        column(:outfitter) { |issue| MeasurementIssueDecorator.decorate(issue).outfitter }
        column(:category_name) { |issue| MeasurementIssueDecorator.decorate(issue).category_name }
        column(:measurement) { |issue| MeasurementIssueDecorator.decorate(issue).measurement_name }
        column(:issue) { |issue| issue.issue_subject.title }
        column(:fixed?) { |issue| to_yes_or_no_string(issue.fixed?) }
        column(:time_to_be_fixed) { |issue| MeasurementIssueDecorator.decorate(issue).time_to_be_fixed }
        column(:comments) { |issue| link_to 'Comments', measurement_issue_mesurement_issue_messages_path(issue), remote: true }
      end
    end
  end

  controller do
    include ApplicationHelper

    def index
      @q = MeasurementIssue.for_measurements.ransack(params[:q])
      @q.sorts = sorting_order
      @issues = @q.result.page(params[:page]).per(20)

      respond_to do |format|
        format.html { super }
        format.csv { send_data Exporters::Objects::Issues.new(records: @q.result).call, filename: "measurement_issues_#{Time.now.to_s(:long)}.csv" }
      end
    end

    private

    def sorting_order
      return 'measurement_profile_customer_id desc' unless params[:order]

      splitted_params = params[:order].split('_')

      sort_order = splitted_params.pop
      sort_column = splitted_params.join('_')

      "#{sort_column} #{sort_order}"
    end
  end
end
