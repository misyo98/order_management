class AccountingDecorator < LineItemCsvDecorator
  delegate_all

  def customer_id
    order_customer_id
  end

  def billing_country
    order_billing_country
  end

  def shipping_country
    order_shipping_country
  end

  def item_subtotal
    @item_subtotal ||= subtotal.to_f / 100
  end

  def item_total
    @total ||= total.to_f / 100
  end

  def discount
    (item_subtotal - item_total).round(2)
  end

  def refunded_amount
    amount_refunded
  end

  def vat_rate
    return @vat_rate if defined?(@vat_rate)
    rates = vat_rates.select { |vat_rate| vat_rate.valid_from <= paid_date }.group_by(&:shipping_country)
    rates = filter_max(rates)

    case shipping_country
    when 'GB', 'SG'
      @vat_rate = rates.detect { |vat_rate| vat_rate.shipping_country == shipping_country }&.rate
    else
      @vat_rate = rates.detect { |vat_rate| vat_rate.shipping_country == 'Other' }&.rate
    end
  end

  def total_after_refund
    @total_after_refund ||= (item_total - refunded_amount.to_f).round(2)
  end

  def total_after_refund_sgd
    if currency == 'GBP'
      (total_after_refund * current_fx_rate&.usd_sgd.to_f / current_fx_rate&.usd_gbp.to_f).round(2)
    else
      total_after_refund
    end
  end

  def total_net_vat
    @total_net_vat ||= (total_after_refund.to_f / (1 + vat_rate.to_f)).round(2)
  end

  def cmt_cost_usd
    return @cmt_cost_us if defined?(@cmt_cost_us)

    cog = search_for_estimated_cog(query: build_cmt_query, cogs: estimated_cogs_list)
    @cmt_cost_usd = cog&.cmt
  end

  def fabric_consumption
    return @fabric_consumption if defined?(@fabric_consumption)

    cog = search_for_estimated_cog(query: build_cmt_query, cogs: estimated_cogs_list)
    @fabric_consumption = cog&.fabric_consumption
  end

  def fabric_cost
    @fabric_cost ||= fabric&.usd_for_meter
  end

  def manufacturing_costs
    @manufacturing_costs ||= (cmt_cost_usd.to_f + fabric_consumption.to_f * fabric_cost.to_f).round(2)
  end

  def estimated_inbound_shipping_costs
    return @estimated_inbound_shipping_costs if defined?(@estimated_inbound_shipping_costs)

    cog = search_for_estimated_cog(query: build_cmt_query, cogs: estimated_cogs_list)
    @estimated_inbound_shipping_costs = cog&.estimated_inbound_shipping_costs
  end

  def estimated_duty
    return @estimated_duty if defined?(@estimated_duty)

    cog = search_for_estimated_cog(query: build_cmt_query, cogs: estimated_cogs_list)
    @estimated_duty = cog&.estimated_duty
  end

  def estimated_cogs
    (manufacturing_costs.to_f + estimated_inbound_shipping_costs.to_f + estimated_duty.to_f).round(2)
  end

  def real_manufacturing_costs
    @real_manufacturing_costs ||= real_cog_cogs_rc_usd
  end

  def real_cogs_fabric_addition_per_meter
    @real_cogs_fabric_addition_per_meter ||= fabric&.fabric_addition
  end

  def real_cogs_fabric_addition_total
    (fabric_consumption.to_f * real_cogs_fabric_addition_per_meter.to_f).round(2)
  end

  def real_cogs_fabric_cmt_and_fabric_addition
    @real_cogs_fabric_cmt_and_fabric_addition ||= (real_manufacturing_costs.to_f + real_cogs_fabric_addition_total.to_f).round(2)
  end

  def real_inbound_shipping_costs
    real_inbound_ship_cost
  end

  def real_duty_usd
    real_duty
  end

  def real_cogs_landed_usd
    @real_cogs_landed_usd ||= real_cogs_fabric_cmt_and_fabric_addition.to_f + real_inbound_shipping_costs.to_f + real_duty.to_f
  end

  def fx_usd_local_currency
    return @fx_usd_local_currency if defined?(@fx_usd_local_currency)

    @fx_usd_local_currency =
      case currency
      when 'SGD'
        current_fx_rate&.usd_sgd
      else
        current_fx_rate&.usd_gbp
      end
  end

  def real_cogs_landed_local_currency
    @real_cogs_landed_local_currency ||= (real_cogs_landed_usd * fx_usd_local_currency.to_f).round(2)
  end

  def margin
    value = ((total_net_vat - real_cogs_landed_local_currency) / total_net_vat).round(2) * 100
    "#{value}%"
  end

  def alteration_costs
    alteration_summaries.sum(:amount)
  end

  def vat_export_field
    return if vat_export.nil?

    vat_export ? 'YES' : 'NO'
  end

  def manufacturer
    LineItem::MANUFACTURERS[object.manufacturer.to_sym]
  end

  def tags_field
    tags.map(&:name).join(', ')
  end

  def remake_category_field
    remake_category.join(', ')
  end

  def fabric_ordered_field
    fabric_ordered? ? 'Yes' : 'No'
  end

  private

  def build_cmt_query
    return @cmt_query if defined?(@cmt_query)

    q_country   = currency_to_country
    q_category  = category&.strip
    q_canvas    = canvas
    @cmt_query = { country: q_country, category: q_category, canvas: q_canvas }
  end

  def search_for_estimated_cog(query:, cogs: )
    return @estimated_cog if defined?(@estimated_cog)

    up_to_date_cogs = cogs.select { |cog| cog.valid_from <= paid_date }.group_by { |cog| [cog.country, cog.category, cog.canvas] }
    up_to_date_cogs = filter_max(up_to_date_cogs)

    @estimated_cog =
      if query[:canvas].present?
        up_to_date_cogs.find { |cog| cog.country == query[:country] && cog.category == query[:category] && cog&.canvas&.scan(query[:canvas])&.any? }
      else
        up_to_date_cogs.find { |cog| cog.country == query[:country] && cog.category == query[:category] }
      end
  end

  def currency_to_country
    currency == 'SGD' ? 'SG' : 'GB'
  end

  def filter_max(collection)
    collection.inject([]) { |array, data_array| array << data_array[1].max_by(&:valid_from); array }
  end

  def current_fx_rate
    @fx_rate ||= fx_rates.select { |fx_rate| fx_rate.valid_from <= paid_date }.max_by(&:valid_from)
  end

  def fx_rates
    @fx_rates ||= h.assigns['fx_rates'] || context[:fx_rates] || FxRate.all
  end

  def vat_rates
    @vat_rates ||= h.assigns['vat_rates'] || context[:vat_rates] || VatRate.all
  end

  def estimated_cogs_list
    @estimated_cogs_list ||= h.assigns['estimated_cogs'] || context[:estimated_cogs] || EstimatedCog.all
  end
end
