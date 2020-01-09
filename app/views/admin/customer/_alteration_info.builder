context.instance_eval  do
  tr do
    td 'Comment', colspan: profile.alteration_colspan
    infos[category_id].each { |alteration_info| td span(alteration_info.comment, class: 'hover-text') }
    td
  end
  tr do
    td 'Alteration Manufacturer ID', colspan: profile.alteration_colspan
    infos[category_id].each { |alteration_info| td alteration_info.manufacturer_code }
    td
  end
  tr do
    td 'Alteration created by', colspan: profile.alteration_colspan
    infos[category_id].each { |alteration_info| td alteration_info.author.email }
    td
  end
  tr do
    td 'Alteration created at', colspan: profile.alteration_colspan
    infos[category_id].each { |alteration_info| td alteration_info.created_at.strftime('%B %d, %Y %H:%M') }
    td
  end
end
