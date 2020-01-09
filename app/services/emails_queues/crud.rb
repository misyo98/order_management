module EmailsQueues
  class CRUD
    CREATED = { created: true }.freeze
    FAILED = { created: false }.freeze

    def initialize(args)
      @args = args
      @recipient = args.dig(:recipient)
      @subject = args.dig(:subject)
      @tracking_number = args.dig(:tracking_number)
    end

    def create
      email = EmailsQueue.new(email_attrs)
      if email.valid?
        email.save
        email.send!(with_delay: 10)
        CREATED
      else
        FAILED
      end
    end

    private

    attr_reader :args, :recipient, :subject, :tracking_number

    def email_attrs
      {
        recipient: recipient,
        subject: subject,
        tracking_number: tracking_number,
        delivery_email_layout: args.dig(:delivery_email_layout),
        options: {
          link: args.dig(:options, :link),
          from: args.dig(:options, :from),
          type: args.dig(:options, :type),
          subject: args.dig(:options, :subject)
        }
      }
    end
  end
end
