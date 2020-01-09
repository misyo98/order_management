namespace :chinos do
  task add_chino_params: :environment do
    ActiveRecord::Base.transaction do
      begin
        chinos_inseam_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Inseam', 'categories.name' => 'Pants')
        chinos_outseam_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Outseam', 'categories.name' => 'Pants')
        pants_inseam = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam)', 'categories.name' => 'Pants')

        Profile.with_category('Pants').find_each do |profile|
          next if profile.measurements.exists?(category_param: chinos_inseam_param)

          profile_pants_inseam = profile.find_measurement(pants_inseam.id)

          next if profile_pants_inseam.blank?

          chinos_inseam = profile.measurements.create!(category_param: chinos_inseam_param, final_garment: profile_pants_inseam.final_garment,
                                                       post_alter_garment: profile_pants_inseam.post_alter_garment)
          chinos_outseam = profile.measurements.create!(category_param: chinos_outseam_param, final_garment: profile_pants_inseam.final_garment,
                                                        post_alter_garment: profile_pants_inseam.post_alter_garment)

          profile_pants_inseam.alterations.each do |alteration|
            chinos_inseam.alterations.create!(alteration_summary_id: alteration.alteration_summary_id, author_id: alteration.author_id, value: nil)
            chinos_outseam.alterations.create!(alteration_summary_id: alteration.alteration_summary_id, author_id: alteration.author_id, value: nil)
          end
        end
      rescue => error
        puts error
        raise ActiveRecord::Rollback
      end
    end
  end

  task remove_chino_params: :environment do
    chinos_inseam_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Inseam', 'categories.name' => 'Pants')
    chinos_outseam_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Outseam', 'categories.name' => 'Pants')

    Measurement.where(category_param: chinos_inseam_param).destroy_all
    Measurement.where(category_param: chinos_outseam_param).destroy_all
  end
end
