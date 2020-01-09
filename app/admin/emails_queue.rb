ActiveAdmin.register EmailsQueue do
  decorate_with EmailsQueueDecorator

  menu label: 'Emails Queue', if: -> { can? :send, EmailsQueue }

  actions :all, except: [:new, :edit]

  filter :tracking_number
  filter :customer_email, as: :string
  filter :customer_first_name, as: :string, label: 'Customer First Name'
  filter :customer_last_name, as: :string, label: 'Customer Last Name'

  permit_params %i(recipient_id recipient_type subject_id subject_type
                   options tracking_number sent_at deleted_at delivery_email_layout)

  index title: 'Emails Queue', download_links: -> { can?(:download_csv, EmailsQueue) } do
    selectable_column
    id_column
    column('Customer') { |email| email.customer_name }
    column('Email') { |email| email.customer_email }
    column(:type) { |email| email.options[:type] }
    column(:tracking_number)
    column(:link)
    column('Sent', humanize_name: false) { |email| email.sent_field }
    column('Delivering Errors') { |email| email.delivering_errors.join('; ') }
    column(:delivery_email_layout) { |email| email.delivery_email_layout_field }
    column(:sent_date)
    column(:created_at) { |email| l(email.created_at, format: :order_date) }
    column(:from)
    actions do |email|
      item 'Force Send!', send_email_emails_queue_path(email), class: 'view_link member_link' if email.failed_to_be_sent?
    end
  end

  member_action :send_email, method: :get

  controller do
    def send_email
      email = EmailsQueue.find_by(id: params[:id])
      result = email.send!

      flash[result[:flash]] = result[:message]
      redirect_to emails_queues_path
    end

    def destroy
      EmailsQueue.find_by(id: params[:id])&.delete_from_sidekiq!
      super
    end
  end
end
