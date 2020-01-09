# frozen_string_literal: true

class FabricInfoDecorator < Draper::Decorator
  delegate_all

  def fabric_book_field
    if limited_fabrics_access?
      fabric_book.title
    else
      h.content_tag(:span, id: "fabric_info_#{id}_fabric_book") do
        h.link_to fabric_book_id, h.fabric_book_path(id: fabric_book_id) unless fabric_book_id.nil?
      end.html_safe
    end
  end

  def fabric_brand_field
    if limited_fabrics_access?
      fabric_brand.title
    else
      h.content_tag(:span, id: "fabric_info_#{id}_fabric_brand") do
        h.link_to fabric_brand_id, h.fabric_brand_path(id: fabric_brand_id) unless fabric_brand_id.nil?
      end.html_safe
    end
  end

  def fabric_tier_field
    if fabric_tier
      h.content_tag(:span, id: "fabric_info_#{id}_tier_prices") do
        h.link_to 'Tier Prices', h.fabric_tier_prices_fabric_info_path(id: id), remote: true, class: 'btn btn-sm btn-info'
      end
    end
  end

  def oos_or_discontinued_warning_label
    case fabric_manager&.status
    when 'out_of_stock' then 'out-of-stock-warning'
    when 'discontinued' then 'discontinued-warning'
    end
  end

  def oos_or_discontinued_field
    return '' unless fabric_manager

    if fabric_manager.out_of_stock?
      "OOS (restock date #{resolve_restock_date(fabric_manager.estimated_restock_date)})"
    else
      'Discontinued'
    end
  end

  private

  def limited_fabrics_access?
    h.current_user.limited_fabrics_access?
  end

  def resolve_restock_date(date)
    date.blank? ? 'undetermined' : date.to_date
  end
end
