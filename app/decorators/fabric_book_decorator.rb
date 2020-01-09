# frozen_string_literal: true

class FabricBookDecorator < Draper::Decorator
  delegate_all

  def fabric_infos_id_links
    if fabric_infos.any?
      fabric_infos.pluck(:id).each_with_object([]) do |id, ids_array|
        ids_array << (h.link_to id, h.fabric_info_path(id))
      end.join(', ').html_safe
    else
      'Was not used anywhere'
    end
  end

  def archived_field
    deleted? ? "Archived: #{deleted_at}" : 'No'
  end
end
