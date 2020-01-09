module Exporters
  class Objects::Accountings < Exporters::Base
    private

    attr_reader :vat_rates, :estimated_cogs, :fx_rates

    def after_initialize
      @vat_rates        = VatRate.all
      @estimated_cogs   = EstimatedCog.all
      @fx_rates         = FxRate.all
    end

    def process
      fast_fields_xls
    end

    def fast_fields_xls
      CSV.generate(headers: true) do |csv|
        unless options[:no_header]
          csv << [
            'ID',
            'FIRST NAME',
            'STATUS',
            'ORDER NO.',
            'ORDER DATE',
            'WC STATUS',
            'LAST NAME',
            'COUNTRY (BILLING)',
            'COUNTRY (SHIPPING)',
            'EMAIL',
            'Currency',
            'Subtotal',
            'Total (gross)',
            'Discount',
            'SALES PERSON',
            'LOCATION OF SALE',
            'Category',
            'Canvas',
            'Fabric Code',
            'RC Fabric Code',
            'Refunded amount',
            'Total (gross) after refund',
            'Total (gross) after refund (SGD)',
            'VAT rate',
            'Total (net VAT)',
            'CMT cost (USD)',
            'Fabric consumption (m)',
            'Fabric cost / M (USD)',
            'Manufacturing costs (USD)',
            'Estimated Inbound shipping costs (USD)',
            'Estimated Duty (USD)',
            'Estimated COGS (landed) - USD',
            'Real Manufacturing Costs (Real, USD)',
            'Real COGS - Fabric Addition per meter (USD)',
            'Real COGS - Fabric Addition total (USD)',
            'Real COGS - CMT & Fabric Addition (USD)',
            'Real Inbound shipping costs (USD)',
            'Real Duty (USD)',
            'Real COGS - Landed (USD)',
            'Manufacturer Order Number',
            'FX USD/Local Currency',
            'Real COGS - Landed (local currency)',
            'Margin',
            'Remake',
            'Courier Company',
            'Outbound Tracking Number',
            'Refund Reason',
            'Coupons',
            'VAT Export',
            'Customer Type',
            'Manufacturer',
            'Comment for tailor',
            'Fabric Ordered?',
            'Fabric Tracking Number',
            'Tags',
            'Fabric Brand',
            'Remake Category',
            'Acquisition Channel',
            'Non Altered Items',
            'Garment Fit',
            'Occasion Date',
            'Customer Note',
            'Special Customizations',
            'Days in current state',
            'Product Title',
            'Remind to get measured'
          ]
        end

        records.find_each do |record|
          r = AccountingDecorator.decorate(
                record,
                context: {
                  vat_rates: vat_rates,
                  estimated_cogs: estimated_cogs,
                  fx_rates: fx_rates
                }
              )
          csv << [
            r.id,
            r.first_name,
            r.status,
            r.order_number,
            r.order_date,
            r.wc_status,
            r.last_name,
            r.billing_country,
            r.shipping_country,
            r.email,
            r.currency,
            r.item_subtotal,
            r.item_total,
            r.discount,
            r.sales_person_field,
            r.location_of_sale,
            r.category,
            r.canvas,
            r.fabric_code,
            r.manufacturer_fabric_code,
            r.refunded_amount,
            r.total_after_refund,
            r.total_after_refund_sgd,
            r.vat_rate,
            r.total_net_vat,
            r.cmt_cost_usd,
            r.fabric_consumption,
            r.fabric_cost,
            r.manufacturing_costs,
            r.estimated_inbound_shipping_costs,
            r.estimated_duty,
            r.estimated_cogs,
            r.real_manufacturing_costs,
            r.real_cogs_fabric_addition_per_meter,
            r.real_cogs_fabric_addition_total,
            r.real_cogs_fabric_cmt_and_fabric_addition,
            r.real_inbound_shipping_costs,
            r.real_duty_usd,
            r.real_cogs_landed_usd,
            r.manufacturer_order_number,
            r.fx_usd_local_currency,
            r.real_cogs_landed_local_currency,
            r.margin,
            r.is_remake,
            r.courier_company,
            r.outbound_tracking_number,
            r.refund_reason,
            r.coupons,
            r.vat_export,
            r.customer_type,
            r.manufacturer,
            r.comment_for_tailor,
	          r.fabric_ordered_field,
            r.fabric_tracking_number,
            r.tags_field,
            r.fabric_brand,
            r.remake_category_field,
            r.customer_acquisition_channel,
            r.non_altered_items,
            r.garment_fit,
            r.occasion_date,
            r.customer_note,
            r.special_customizations_field,
            r.maybe_days_in_state_field,
            r.product_title,
            r.model.remind_to_get_measured
          ]
        end
      end
    end
  end
end
