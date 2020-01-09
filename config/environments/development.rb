Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.preview_path = "#{Rails.root}/test/mailers/previews"

  # ActionMailer::Base.sendmail_settings = { 
  #   location: '/usr/sbin/sendmail', 
  #   arguments:'-i -t -f support@editsuits.com'
  # }
  config.action_mailer.default_options = {
    from: "noreply@example.com" 
  }
  config.active_job.queue_adapter = :sidekiq
  ActionMailer::Base.register_observer(MailObserver)

  # Staging doesn't work with this
  # Sidekiq.configure_server do |config|
  #   config.server_middleware do |chain|
  #     chain.add Sidekiq::Middleware::Server::RetryJobs, max_retries: 0
  #   end
  #   config.error_handlers << Proc.new {|exception, context_hash| EmailsQueues::ErrorHandler.handle(exception, context_hash) }
  # end

  # config.action_mailer.perform_deliveries = false
  # config.action_mailer.raise_delivery_errors = true
  # config.action_mailer.default_url_options = { host: 'orders.editsuits.com'}
  # config.action_mailer.default_options = { from: 'support@editsuit.com' }
  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.action_mailer.delivery_method = :letter_opener_web
  config.action_mailer.perform_deliveries = true

  config.action_mailer.default_url_options = { host: 'http://ordertest.editsuits.com' }
  # config.action_mailer.smtp_settings = {      
  #   :address              => "smtp.gmail.com",      
  #   :port                 => 587,      
  #   :domain               => "gmail.com",      
  #   :user_name            => "alex@lime.net.ua",      
  #   :password             => "FORSAG",      
  #   :authentication       => :plain,      
  #   :enable_starttls_auto => true  }

  # White list IP for Google DataStudio connection
  config.web_console.whitelisted_ips = '5.9.50.86'
end
