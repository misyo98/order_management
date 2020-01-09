context.instance_eval  do
  creation_comment = decorated_comments.find_and_decorate_comment(category_id, false)
  submission_comment = decorated_comments.find_and_decorate_comment(category_id, true)

  tr do
    td 'Comment', colspan: 2
    td class: creation_comment&.maybe_red_class do
      span class: 'hover-text' do
        creation_comment&.body
      end
    end
    td
    td class: submission_comment&.maybe_red_class do
      span class: 'hover-text' do
        submission_comment&.body
      end
    end
    td
    if infos[category_id]
      infos[category_id].each do |alteration_info|
        alteration_info = alteration_info.decorate

        td class: alteration_info.comment_section_any? && 'red-field' do
          span(class: 'hover-text') do
            alteration_info.comment_section
          end
        end
      end
    end
  end
  tr do
    td 'Manufacturer ID', colspan: profile.alteration_colspan
    infos[category_id].each { |alteration_info| td alteration_info.manufacturer_code } if infos[category_id]
  end
  tr do
    td 'Created by', colspan: 2
    td creation_comment&.author_full_name
    td
    td submission_comment&.author_full_name
    td
    infos[category_id].each { |alteration_info| td alteration_info&.author_full_name } if infos[category_id]
  end
  tr do
    td 'Created at', colspan: 2
    td creation_comment&.creation_date
    td
    td submission_comment&.creation_date
    td
    infos[category_id].each { |alteration_info| td alteration_info.created_at.strftime('%B %d, %Y') } if infos[category_id]
  end
  tr do
    td 'Last Updated by', colspan: 2
    td
    td
    td submission_comment&.updater_full_name
    td
  end
  tr do
    td 'Last Updated at', colspan: 2
    td
    td
    td submission_comment&.update_date
    td
  end
end
