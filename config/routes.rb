Rails.application.routes.draw do
  if Rails.env.development?
    require 'sidekiq/web'

    mount LetterOpenerWeb::Engine, at: "/letter_opener"
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: { registrations: 'registrations' }
  ActiveAdmin.routes(self)

  resources :categories, only: :index

  resources :fits, only: [:new, :create]

  resources :customers do
    resources :profile do
      collection do
        get :items
      end
      member do
        patch :submit
        patch :alter
      end
    end
    collection do
      get :info
    end
  end

  resources :measurement_issues do
    resources :mesurement_issue_messages, only: :index, controller: 'measurement_issues/mesurement_issue_messages'
  end

  resources :line_items do
    collection do
      post :import_tracking_numbers
      post :import_csv
      post :update_shipments
    end
    resources :logged_events, only: :index
  end

  resources :alteration_infos, only: [:new, :create]

  resources :measurements do
    collection do
      get :checks
      post :validate
      post :batch_validate
      post :validate_with_dependencies
      post :validate_alteration
    end
  end

  resources :profile_comments, only: :create

  resources :profile_images, only: :destroy

  resources :alteration_summaries, only: [:show, :edit, :update] do
    resources :alteration_images, only: [:destroy, :index]
  end
  resources :columns, only: :update do
    collection do
      patch :reorder
      patch :batch_update
    end
  end

  get   :new_shipping_costs_and_duties, to: 'accounting#new_shipping_costs_and_duties'
  post  :create_shipping_costs_and_duties, to: 'accounting#create_shipping_costs_and_duties'
  get   :generate_csv, to: 'accounting#generate_csv'
  get   :download_csv, to: 'accounting#download_csv'
  get   :fabric_category_select, to: 'fabric_editor#fabric_category_select'
  get   :fabric_form, to: 'fabric_editor#fabric_form'
  patch :create_fabric_group, to: 'fabric_editor#create_fabric_group'
  get   :fabric_management, to: 'fabric_managers#fabric_management'

  resources :remaining_cogs, only: [:index] do
    collection do
      get   :batch_edit_buckets
      patch :batch_update_buckets
    end
  end

  resources :dropdown_list_values, only: [] do
    collection do
      get  :download_csv
      get  :import
      post :do_import
    end
  end

  resources :orders, only: %i(show update)

  namespace :booking_tool do
    resources :appointments do
      member do
        patch :called
        get   :call_later
        patch :update_callback_date
        get   :call_history
        patch :removed_by_ops
        patch :no_show
      end
      collection do
        get :set_default_calendars
        get :booking_history
        get :generate_csv
        get :export_csv
        get :dropped_events
      end
    end
  end

  namespace :api do
    resources :users, only: [:index]
    resources :sales_locations, only: [:index]
    resources :customers do
      resources :profiles, only: :create
      collection do
        get   :show_by_token
        post  :filter
        get   :load_customers
        patch :trigger_delivery_arranged
        patch :cancel_delivery
        patch :set_acquisition_channel
        patch :prepare_shipment_for_courier_delivery
        patch :update_delivery_date
      end
      member do
        get :category_statuses
      end
    end
    resources :accountings, only: :index
    scope '/orders/:order_id' do
      resources :line_items, only: :index
    end
  end

  namespace :woocommerce do
    namespace :webhooks do
      resources :customers, only: :create
      resources :orders, only: :create
      resources :products, only: :create
    end
  end
end
