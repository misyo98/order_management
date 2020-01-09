module Exporters
  class Objects::CustomersWaistcoats < Exporters::Base
    WAISTCOAT_CATEGORY = :waistcoat
    CHEST = :waistcoat_chest
    WAIST = :waistcoat_waist
    POINTED_FRONT = :waistcoat_front_pointed
    STRAIGHT_FRONT = :waistcoat_front_straight
    BACK_LENGTH = :waistcoat_back_length
    FIRST_BUTTON = :waistcoat_1st_button
    WAISTCOAT = 'Waistcoat'.freeze
    BLANK_MEASUREMENTS = [nil,nil,nil,nil,nil,nil].freeze

    private

    def process
      fast_fields_xls
    end

    def fast_fields_xls
      CSV.generate(headers: true) do |csv|
        csv << [
          'CUSTOMER ID',
          'FIRST NAME',
          'LAST NAME',
          'Waistcoat Chest - Final Garment',
          'Waistcoat Waist - Final Garment',
          'Waistcoat Front Length (pointed) - Final Garment',
          'Waistcoat Front Length (straight) - Final Garment',
          'Waistcoat Back Length - Final Garment',
          'Waistcoat 1st Button Position - Final Garment',
          'Waistcoat Measurement Status'
        ]

        records.each do |customer|
          csv << ([customer.id, customer.first_name, customer.last_name] +
                 waistcoat_measurements(customer.profile) +
                 [customer.profile&.category_status(WAISTCOAT)])
        end
      end
    end

    def waistcoat_measurements(profile)
      return BLANK_MEASUREMENTS unless profile

      waistcoat_category_param_ids.map do |measurement, category_param_id|
        profile.find_measurement(category_param_id)&.decorate&.post_alter_garment_field
      end
    end

    def waistcoat_category_param_ids
      @waistcoat_category_param_ids ||=
        {
          chest: CategoryParam.find_param(WAISTCOAT_CATEGORY, CHEST).id,
          waist: CategoryParam.find_param(WAISTCOAT_CATEGORY, WAIST).id,
          pointed_front: CategoryParam.find_param(WAISTCOAT_CATEGORY, POINTED_FRONT).id,
          straight_front: CategoryParam.find_param(WAISTCOAT_CATEGORY, STRAIGHT_FRONT).id,
          back_length: CategoryParam.find_param(WAISTCOAT_CATEGORY, BACK_LENGTH).id,
          first_button: CategoryParam.find_param(WAISTCOAT_CATEGORY, FIRST_BUTTON).id
        }
    end
  end
end
