module Woocommerce
  class NoteApi < API

    ITEMS_LIMIT = 100

    private

    def after_initialize(args)
      @params           = nil
      @response_headers = nil
      @total_items      = nil
      @last_page        = nil
    end
  end
end