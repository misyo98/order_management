module LineItems
  class BatchStateTrigger
    Response = Struct.new(:success?, :pretty_errors, :errors, :message, :items, :ids, :event)

    def initialize(params)
      @params         = params
      @items          = LineItem.where(id: params.fetch(:ids, []))
      @user_id        = params.fetch(:user_id, 0)
      @event          = params.fetch(:event)
      @errors         = []
      @pretty_errors  = []
    end

    def call
      perform
      form_response
    end

    private

    attr_accessor :errors, :items, :pretty_errors
    attr_reader   :user_id, :event, :params

    def response(success:, pretty_errors:, errors:, message: '')
      Response.new(success, pretty_errors, errors, message, items, params.fetch(:ids, []), event)
    end

    def perform
      ActiveRecord::Base.transaction do
        items.each do |item|
          begin
            item.public_send("#{event}!", user_id: user_id)
          rescue StateMachines::InvalidTransition => error
            item.errors.each { |key, value| errors << { attribute: key, message: value } } 
            pretty_errors << "Item with ID: #{item.id} is not valid for a state change"
          end
        end

        raise ActiveRecord::Rollback if pretty_errors.any?
      end
    end

    def form_response
      message =
        if pretty_errors.any?
          'Some errors occurred during state change'
        else
          "#{items.count} items was successfully updated"
        end

      response(success: pretty_errors.empty?, pretty_errors: pretty_errors, errors: errors, message: message)
    end
  end
end
