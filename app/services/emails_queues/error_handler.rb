module EmailsQueues
  class ErrorHandler
    def self.handle(*args)
      self.new(*args).handle
    end

    def initialize(exception, context_hash)
      @context = context_hash.with_indifferent_access
      @email = EmailsQueue.find_by(jid: context[:args]&.first[:job_id])
    end

    def handle
      return unless email

      email.add_error("#{context[:error_class]}: #{context[:error_message]}")
    end

    private

    attr_reader :context, :email
  end
end
