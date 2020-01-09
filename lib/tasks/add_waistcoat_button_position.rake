task add_waistcoat_button_position: :environment do
  ActiveRecord::Base.transaction do
    begin
      waistcoat_button_position_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Waist (Button Position)', 'categories.name' => 'Waistcoat')
      waistcoat_back_length_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Waistcoat Back Length', 'categories.name' => 'Waistcoat')
      jacket_button_position_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Waist (Button Position)', 'categories.name' => 'Jacket')

      Profile.with_category('Waistcoat').find_each do |profile|
        next if profile.measurements.exists?(category_param: waistcoat_button_position_param)

        profile_waistcoat_back_length = profile.find_measurement(waistcoat_back_length_param.id)
        profile_jacket_button_position = profile.find_measurement(jacket_button_position_param.id)

        waistcoat_button_position = profile.measurements.create!(category_param: waistcoat_button_position_param, final_garment: profile_jacket_button_position&.final_garment,
                                                                 post_alter_garment: profile_jacket_button_position&.post_alter_garment)

        profile_waistcoat_back_length&.alterations&.each do |alteration|
          waistcoat_button_position.alterations.create!(alteration_summary_id: alteration.alteration_summary_id, author_id: alteration.author_id, value: nil)
        end
      end
    rescue => error
      puts error
      raise ActiveRecord::Rollback
    end
  end
end
