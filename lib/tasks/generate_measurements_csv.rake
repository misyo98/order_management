require 'csv'

task :generate_measurements_csv => :environment do
  
  file = "#{Rails.root}/public/measurements.csv"

  column_headers = [
    'Customer ID', 'Customer Name', 'Height Fit', 'Height Measurements Status', 'Height Height (inches)', 'Height Height (cm)',
    'Shirt Fit', 'Shirt Measurements Status', 'Shirt Neck', 'Shirt Chest', 'Shirt Waist (Button Position)', 'Shirt Waist (Belly Button)',
    'Shirt Hip', 'Shirt Shoulder', 'Shirt Shirt Sleeve Length (left sleeve)', 'Shirt Shirt Sleeve Length (right sleeve)',
    'Shirt Wrist / Cuff - Button cuff - without watch', 'Shirt Wrist / Cuff - Button cuff - with watch', 'Shirt Wrist / Cuff - French cuff - without watch',
    'Shirt Wrist / Cuff - French cuff - with watch', 'Shirt Biceps', 'Shirt Shirt Length (front) - Tuck-in', 'Shirt Shirt length (back) - Tuck-in',
    'Shirt Shirt length (front) - Tuck-out', 'Shirt Shirt length (back) - Tuck-out', 'Jacket Fit', 'Jacket Measurements Status', 'Jacket Neck',
    'Jacket Chest', 'Jacket Waist (Button Position)', 'Jacket Waist (Belly Button)', 'Jacket Hip', 'Jacket Shoulder', 'Jacket Jacket Sleeve Length (left sleeve)',
    'Jacket Jacket Sleeve Length (right sleeve)', 'Jacket Wrist / Cuff', 'Jacket Biceps',	'Jacket Jacket Length (front)', 'Jacket Jacket Length (back)',
    'Jacket Button position - 2 buttons', 'Jacket Button position - 1 buttons', 'Pants Fit', 'Pants Measurements Status', 'Pants Pant Waist',
    'Pants Hip - Pants - No pleats', 'Pants Hip - Pants - With pleats', 'Pants Rise',	'Pants Thigh', 'Pants Knee', 'Pants Calf', 'Pants Pant cuff',
    'Pants Pant length (outseam left leg)', 'Pants Pant length (outseam right leg)', 'Waistcoat Fit', 'Waiscoat Measurements Status', 'Waistcoat Waistcoat Chest',
    'Waistcoat Waist (Button Position)', 'Waistcoat Waist (Belly Button)',	'Waistcoat Waistcoat Front Length (pointed)', 'Waistcoat Waistcoat Front Length (straight)',
    'Waistcoat Waistcoat Back Length',	'Waistcoat Waistcoat 1st Button Position', 'Overcoat Fit', 'Overcoat Measurements Status', 'Overcoat Neck',
    'Overcoat Chest', 'Overcoat Waist',	'Overcoat Hip', 'Overcoat Shoulder', 'Overcoat Overcoat Sleeve length (left sleeve)',
    'Overcoat Overcoat Sleeve length (right sleeve)', 'Overcoat Biceps', 'Overcoat Overcoat Front Length', 'Overcoat Overcoat Back Length',
    'Overcoat Button Position', 'Chinos Fit', 'Chinos Measurements Status', 'Chinos Pant Waist',	'Chinos Hip - Pants - No pleats',
    'Chinos Hip - Pants - With pleats',	'Chinos Rise', 'Chinos Thigh', 'Chinos Knee',	'Chinos Calf', 'Chinos Pant cuff', 'Chinos Pant length (outseam left leg)',
    'Chinos Pant length (outseam right leg)', 'Body shape & postures Body type', 'Body shape & postures Front shoulder',
    'Body shape & postures Shoulder slope - Left', 'Body shape & postures Shoulder Slope - Right', 'Body shape & postures Square Back Neck?',
    'Body shape & postures Prominent Chest?', 'Body shape & postures Sleeve pitch', 'Body shape & postures Prominent Seat?',
    'Body shape & postures Lower waistband in front', 'Body shape & postures Armhole', 'Body shape & postures Back Shape', 'Body shape & postures Hem'
  ]

  CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
    customers = Customer.joins(profile: :categories).where(ProfileCategory.arel_table[:status].eq(2)).uniq.order(:id)
    customers.each do |customer|

      height_status    = customer.profile&.categories&.find_by(category_id: 1)&.status
      shirt_status     = customer.profile&.categories&.find_by(category_id: 2)&.status
      jacket_status    = customer.profile&.categories&.find_by(category_id: 3)&.status
      pants_status     = customer.profile&.categories&.find_by(category_id: 4)&.status
      waistcoat_status = customer.profile&.categories&.find_by(category_id: 5)&.status
      overcoat_status  = customer.profile&.categories&.find_by(category_id: 6)&.status
      chinos_status    = customer.profile&.categories&.find_by(category_id: 7)&.status
      body_status      = customer.profile&.categories&.find_by(category_id: 8)&.status
      
      fit_confirmed = -> (id, status) { status == 'confirmed' ? customer.profile&.fits&.find_by(category_id: id)&.fit : nil }
      status_confirmed = -> (status) { status == 'confirmed' ? status : nil }
      final_value = -> (id, status) { status == 'confirmed' ? customer.profile&.measurements&.find_by(category_param_id: id)&.decorate&.post_alter_garment_field : nil }

      writer << ([customer.id, customer.full_name] + [ fit_confirmed.call(1, height_status),
        status_confirmed.call(height_status), final_value.call(1, height_status), final_value.call(2, height_status),
        fit_confirmed.call(2, shirt_status), status_confirmed.call(shirt_status),
        final_value.call(3, shirt_status), final_value.call(4, shirt_status), final_value.call(5, shirt_status), final_value.call(6, shirt_status),
        final_value.call(7, shirt_status), final_value.call(8, shirt_status), final_value.call(78, shirt_status), final_value.call(79, shirt_status),
        final_value.call(10, shirt_status), final_value.call(11, shirt_status), final_value.call(12, shirt_status), final_value.call(13, shirt_status),
        final_value.call(14, shirt_status), final_value.call(15, shirt_status), final_value.call(16, shirt_status), final_value.call(17, shirt_status),
        final_value.call(18, shirt_status), fit_confirmed.call(3, jacket_status), status_confirmed.call(jacket_status),
        final_value.call(19, jacket_status), final_value.call(20, jacket_status), final_value.call(21, jacket_status), final_value.call(22, jacket_status),
        final_value.call(23, jacket_status), final_value.call(24, jacket_status), final_value.call(82, jacket_status), final_value.call(83, jacket_status),
        final_value.call(26, jacket_status), final_value.call(27, jacket_status), final_value.call(28, jacket_status), final_value.call(29, jacket_status),
        final_value.call(30, jacket_status), final_value.call(31, jacket_status), fit_confirmed.call(4, pants_status),
        status_confirmed.call(pants_status), final_value.call(32, pants_status), final_value.call(33, pants_status),
        final_value.call(34, pants_status), final_value.call(35, pants_status), final_value.call(36, pants_status), final_value.call(37, pants_status),
        final_value.call(38, pants_status), final_value.call(39, pants_status), final_value.call(84, pants_status), final_value.call(85, pants_status),
        fit_confirmed.call(5, waistcoat_status), status_confirmed.call(waistcoat_status), final_value.call(42, waistcoat_status),
        final_value.call(100, waistcoat_status), final_value.call(43, waistcoat_status), final_value.call(44, waistcoat_status), final_value.call(45, waistcoat_status),
        final_value.call(46, waistcoat_status), final_value.call(47, waistcoat_status), fit_confirmed.call(6, overcoat_status),
        status_confirmed.call(overcoat_status), final_value.call(48, overcoat_status), final_value.call(49, overcoat_status),
        final_value.call(50, overcoat_status), final_value.call(51, overcoat_status), final_value.call(52, overcoat_status), final_value.call(92, overcoat_status),
        final_value.call(93, overcoat_status), final_value.call(54, overcoat_status), final_value.call(55, overcoat_status), final_value.call(56, overcoat_status),
        final_value.call(57, overcoat_status), fit_confirmed.call(7, chinos_status), status_confirmed.call(chinos_status),
        final_value.call(58, chinos_status), final_value.call(59, chinos_status), final_value.call(60, chinos_status), final_value.call(61, chinos_status),
        final_value.call(62, chinos_status), final_value.call(63, chinos_status), final_value.call(64, chinos_status), final_value.call(65, chinos_status),
        final_value.call(94, chinos_status), final_value.call(95, chinos_status), final_value.call(68, body_status), final_value.call(69, body_status),
        final_value.call(70, body_status), final_value.call(71, body_status), final_value.call(72, body_status), final_value.call(73, body_status),
        final_value.call(75, body_status), final_value.call(76, body_status), final_value.call(77, body_status), final_value.call(98, body_status),
        final_value.call(99, body_status), final_value.call(101, body_status)
      ])
    end
  end
end
