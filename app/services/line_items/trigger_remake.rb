# frozen_string_literal: true

module LineItems
  class TriggerRemake
    PANTS_CATEGORY = 'Pants'
    JACKET_CATEGORY = 'Jacket'

    def self.call(*attrs)
      new(*attrs).call
    end

    def initialize(line_item_id, altered_categories, user_id = nil)
      @user_id = user_id
      @line_item = LineItem.find_by(id: line_item_id)
      @altered_categories = altered_categories
    end

    def call
      if all_item_categories_altered?
        line_item.update_column(:remake_category, nil)
        line_item.remake_requested(user_id: user_id)
      else
        create_remake
      end
    end

    private

    attr_reader :line_item, :altered_categories, :user_id

    def all_item_categories_altered?
      (line_item.local_category - altered_categories).empty?
    end

    def create_remake
      ActiveRecord::Base.transaction do
        begin
          perform_remake
        rescue
          raise ActiveRecord::Rollback
        end
      end
    end

    def perform_remake
      duplicate = line_item.dup
      nullify_revenue(duplicate)
      assign_remake_product(duplicate) if line_item.product.suit?
      remake_item(duplicate)
      line_item.update_column(:remake_category, altered_categories)
    end

    def nullify_revenue(duplicate)
      duplicate.subtotal         = 0
      duplicate.total            = 0
      duplicate.price            = 0
      duplicate.amount_refunded  = 0
    end

    def remake_item(duplicate)
      duplicate.remake = true
      duplicate.m_order_number = nil
      duplicate.m_order_status = nil
      duplicate.tracking_number = nil
      duplicate.shipped_date = nil
      duplicate.shipment_received_date = nil
      duplicate.outbound_tracking_number = nil
      duplicate.alteration_tailor_id = nil
      duplicate.courier_company_id = nil
      duplicate.remake_category = altered_categories
      duplicate.ordered_fabric = nil if duplicate.ordered_fabric?
      duplicate.fabric_tracking_number = nil
      duplicate.fabric_ordered_date = nil

      duplicate.save!
      duplicate.remake_requested!(user_id: user_id)
    end

    def assign_remake_product(duplicate)
      if pants_category?
        duplicate.product = Product.remake_trousers
        duplicate.name = 'Trousers - All Fabrics (Appointment Selection)'
        duplicate.sku = 'ES_TROUSERS_APP'
      elsif jacket_category?
        duplicate.product = Product.remake_jacket
        duplicate.name = 'Jacket - All Fabrics (Appointment Selection)'
        duplicate.sku = 'ES_JACKET_APP'
      end
    end

    def pants_category?
      altered_categories.first == PANTS_CATEGORY
    end

    def jacket_category?
      altered_categories.first == JACKET_CATEGORY
    end
  end
end
