namespace :left_right_items do
  create_items = ->(category, category_params) do
    Profile.with_category(category).find_each do |profile|
      category_params.each do |category_param|
        measurement = profile.find_measurement(category_param[:old].id)
        next if measurement.blank?

        new_measurements = []

        category_param[:new].each do |new_category_param|
          new_measurement = measurement.dup
          new_measurement.category_param = new_category_param
          new_measurement.save!
          new_measurements << new_measurement
        end

        measurement.alterations.each do |alteration|
          new_measurements.each do |new_measurement|
            new_alteration = alteration.dup
            new_alteration.measurement_id = new_measurement.id
            new_alteration.save!
          end
        end
      end
    end
  end

  task add_items: :environment do
    ActiveRecord::Base.transaction do
      begin
        pants_category = 'Pants'
        chinos_inseam_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Inseam', 'categories.name' => 'Pants')
        chinos_inseam_left_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Inseam (left leg)', 'categories.name' => 'Pants')
        chinos_inseam_right_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Inseam (right leg)', 'categories.name' => 'Pants')
        chinos_outseam_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Outseam', 'categories.name' => 'Pants')
        chinos_outseam_left_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Outseam (left leg)', 'categories.name' => 'Pants')
        chinos_outseam_right_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Outseam (right leg)', 'categories.name' => 'Pants')
        pants_inseam = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam)', 'categories.name' => 'Pants')
        pants_inseam_left = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam left leg)', 'categories.name' => 'Pants')
        pants_inseam_right = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam right leg)', 'categories.name' => 'Pants')
        pants_outseam = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (outseam)', 'categories.name' => 'Pants')
        pants_outseam_left = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (outseam left leg)', 'categories.name' => 'Pants')
        pants_outseam_right = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (outseam right leg)', 'categories.name' => 'Pants')

        pants = [pants_category, [ { old: chinos_inseam_param, new: [chinos_inseam_left_param, chinos_inseam_right_param] },
                                   { old: chinos_outseam_param, new: [chinos_outseam_left_param, chinos_outseam_right_param] },
                                   { old: pants_inseam, new: [pants_inseam_left, pants_inseam_right] },
                                   { old: pants_outseam, new: [pants_outseam_left, pants_outseam_right] } ]]
        shirt_category = 'Shirt'
        shirt_sleeve = CategoryParam.joins(:param, :category).find_by('params.title' => 'Shirt Sleeve Length', 'categories.name' => 'Shirt')
        shirt_sleeve_left = CategoryParam.joins(:param, :category).find_by('params.title' => 'Shirt Sleeve Length (left sleeve)', 'categories.name' => 'Shirt')
        shirt_sleeve_right = CategoryParam.joins(:param, :category).find_by('params.title' => 'Shirt Sleeve Length (right sleeve)', 'categories.name' => 'Shirt')

        shirt = [shirt_category, [ { old: shirt_sleeve, new: [shirt_sleeve_left, shirt_sleeve_right] } ]]

        jacket_category = 'Jacket'
        jacket_sleeve = CategoryParam.joins(:param, :category).find_by('params.title' => 'Jacket Sleeve Length', 'categories.name' => 'Jacket')
        jacket_sleeve_left = CategoryParam.joins(:param, :category).find_by('params.title' => 'Jacket Sleeve Length (left sleeve)', 'categories.name' => 'Jacket')
        jacket_sleeve_right = CategoryParam.joins(:param, :category).find_by('params.title' => 'Jacket Sleeve Length (right sleeve)', 'categories.name' => 'Jacket')

        jacket = [jacket_category, [ { old: jacket_sleeve, new: [jacket_sleeve_left, jacket_sleeve_right] } ]]

        overcoat_category = 'Overcoat'
        overcoat_sleeve = CategoryParam.joins(:param, :category).find_by('params.title' => 'Overcoat Sleeve length', 'categories.name' => 'Overcoat')
        overcoat_sleeve_left = CategoryParam.joins(:param, :category).find_by('params.title' => 'Overcoat Sleeve length (left sleeve)', 'categories.name' => 'Overcoat')
        overcoat_sleeve_right = CategoryParam.joins(:param, :category).find_by('params.title' => 'Overcoat Sleeve length (right sleeve)', 'categories.name' => 'Overcoat')

        overcoat = [overcoat_category, [ { old: overcoat_sleeve, new: [overcoat_sleeve_left, overcoat_sleeve_right] } ]]

        chinos_category = 'Chinos'
        chinos_pant_outseam = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (outseam)', 'categories.name' => 'Chinos')
        chinos_pant_left_outseam = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (outseam left leg)', 'categories.name' => 'Chinos')
        chinos_pant_right_outseam = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (outseam right leg)', 'categories.name' => 'Chinos')
        chinos_inseam = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam)', 'categories.name' => 'Chinos')
        chinos_inseam_left = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam left leg)', 'categories.name' => 'Chinos')
        chinos_inseam_right = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam right leg)', 'categories.name' => 'Chinos')

        chinos = [chinos_category, [ { old: chinos_pant_outseam, new: [chinos_pant_left_outseam, chinos_pant_right_outseam] },
                                     { old: chinos_inseam, new: [chinos_inseam_left, chinos_inseam_right] } ]]


        [pants, shirt, jacket, overcoat, chinos].each do |category|
          create_items.call(*category)
        end
      rescue => error
        puts error
        raise ActiveRecord::Rollback
      end
    end
  end

  task remove_old_category_params: :environment do
    chinos_inseam_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Inseam', 'categories.name' => 'Pants')
    chinos_outseam_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Outseam', 'categories.name' => 'Pants')
    pants_inseam = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam)', 'categories.name' => 'Pants')
    pants_outseam = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (outseam)', 'categories.name' => 'Pants')
    shirt_sleeve = CategoryParam.joins(:param, :category).find_by('params.title' => 'Shirt Sleeve Length', 'categories.name' => 'Shirt')
    jacket_sleeve = CategoryParam.joins(:param, :category).find_by('params.title' => 'Jacket Sleeve Length', 'categories.name' => 'Jacket')
    overcoat_sleeve = CategoryParam.joins(:param, :category).find_by('params.title' => 'Overcoat Sleeve length', 'categories.name' => 'Overcoat')
    chinos_pant = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (outseam)', 'categories.name' => 'Chinos')
    chinos_inseam = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam)', 'categories.name' => 'Chinos')
    chinos_inseam_left = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam left leg)', 'categories.name' => 'Chinos')
    chinos_inseam_right = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam right leg)', 'categories.name' => 'Chinos')
    pants_inseam = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam)', 'categories.name' => 'Pants')
    pants_inseam_left = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam left leg)', 'categories.name' => 'Pants')
    pants_inseam_right = CategoryParam.joins(:param, :category).find_by('params.title' => 'Pant length (inseam right leg)', 'categories.name' => 'Pants')
    chinos_outseam_left_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Outseam (left leg)', 'categories.name' => 'Pants')
    chinos_outseam_right_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Outseam (right leg)', 'categories.name' => 'Pants')
    chinos_inseam_left_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Inseam (left leg)', 'categories.name' => 'Pants')
    chinos_inseam_right_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Chino-Inseam (right leg)', 'categories.name' => 'Pants')
    arched_back_param = CategoryParam.joins(:param, :category).find_by('params.title' => 'Arched back', 'categories.name' => 'Body shape & postures')

    [chinos_inseam_param, chinos_outseam_param, pants_inseam, pants_outseam,
     shirt_sleeve, jacket_sleeve, overcoat_sleeve, chinos_pant, chinos_inseam, chinos_inseam_left,
     chinos_inseam_right, pants_inseam, pants_inseam_left, pants_inseam_right, chinos_outseam_left_param,
     chinos_outseam_right_param, chinos_inseam_left_param, chinos_inseam_right_param, arched_back_param].each do |category_param|
      category_param&.destroy
    end
  end
end
