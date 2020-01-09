ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    unless current_user.tailor? || current_user.phone_support?
      columns do
        unless current_user.suit_placing?
          column do
            link_to 'New measurement profile', new_measurement_path, class: [:button, :with_space_bottom, :btn, 'btn-primary']
          end
          column do
            link_to 'Measurements Check', checks_measurements_path, class: [:button, :with_space_bottom, :btn, 'btn-info']
          end
          column do
            link_to 'Appointments List', booking_tool_appointments_path, class: [:button, :with_space_bottom, :btn, 'btn-success']
          end
        end
        column do
          link_to 'Fabrics', fabric_infos_path, class: [:button, :with_space_bottom, :btn, 'btn-warning'] if can?(:index, FabricInfo)
        end
      end
    end

    unless current_user.suit_placing? || current_user.tailor? || current_user.phone_support?
      columns do
        column do
          h3 'Alteration summary'
          span 'Select user and date'
          render partial: "admin/dashboard/form"
        end
      end

      columns do
        column do
          div class: 'summary-table'
          if assigns[:summaries]
            render 'admin/dashboard/alteration_summary', context: self
          end
        end
      end
    end
  end

  controller do
    def index
      if summary_params?
        @summaries = Admin::AlterationSummary.new(user_id:       params[:user_id],
                                                  start:         params[:start_date],
                                                  end_date:      params[:end_date],
                                                  category_ids:  sanitized_ids)
                                             .summary_info
      end
      super
    end

    private

    def summary_params?
      [params[:user_id], params[:start_date], params[:end_date]].all?(&:present?)
    end

    def sanitized_ids
      params.dig(:user_params, :category_ids)&.reject(&:empty?) || []
    end
  end
end
