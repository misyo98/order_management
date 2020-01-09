module Customers
  class ProfileCreator
    MAPPINGS = {
      'neck'            => ['Neck'],
      'chest'           => ['Chest', 'Waistcoat Chest'],
      'upper_waist'     => ['Waist (Button Position)'],
      'lower_waist'     => ['Waist (Belly Button)'],
      'hip'             => ['Hip - Pants - No pleats', 'Hip - Pants - With pleats', 'Hip'],
      'shoulder'        => ['Shoulder'],
      'sleeve_length'   => ['Shirt Sleeve Length (left sleeve)', 'Shirt Sleeve Length (right sleeve)',
                            'Jacket Sleeve Length (left sleeve)', 'Jacket Sleeve Length (right sleeve)'],
      'wrist'           => ['Wrist / Cuff - French cuff - without watch', 'Wrist / Cuff - French cuff - with watch',
                            'Wrist / Cuff - Button cuff - without watch', 'Wrist / Cuff - Button cuff - with watch',
                            'Wrist / Cuff'],
      'bicep'           => ['Biceps'],
      'front_length'    => ['Shirt Length (front) - Tuck-in', 'Shirt length (front) - Tuck-out',
                            'Shirt length (back) - Tuck-in', 'Shirt length (back) - Tuck-out',
                            'Waistcoat 1st Button Position', 'Waistcoat Back Length',
                            'Waistcoat Front Length (straight)', 'Waistcoat Front Length (pointed)',
                            'Button position - 1 buttons', 'Button position - 2 buttons',
                            'Jacket Length (back)', 'Jacket Length (front)'],
      'pant_waist'      => ['Pant Waist'],
      'rise'            => ['Rise'],
      'thigh'           => ['Thigh'],
      'knee'            => ['Knee'],
      'calf'            => ['Pant cuff', 'Calf'],
      'pants_length'    => ['Pant length (outseam left leg)', 'Pant length (outseam right leg)'],
      'body_type'       => ['Body type'],
      'front_shoulder'  => ['Front Shoulder'],
      'shoulder_slope'  => ['Shoulder slope - Left', 'Shoulder slope - Right'],
      'prominent_chest' => ['Prominent Chest?']
    }.freeze
    SHOULDER_SLOPES = ['Shoulder slope - Left', 'Shoulder slope - Right'].freeze
    SHOULDER_SLOPE_MAPPINGS = { 'Low' => 'C', 'Regular' => 'A', 'High' => 'E' }.freeze
    HEIGHT_VALUES = ['Height (inches)', 'Height (cm)'].freeze
    HEIGHT_IN_NAME = 'Height (inches)'.freeze
    HEIGHT_CM_NAME = 'Height (cm)'.freeze
    CMS = 'cm'.freeze
    INCHES_DIVIDER = 2.54
    ROUND_VALUE = 2
    HEIGHT_CM_KEY = 'height_cm'.freeze
    HEIGHT_IN_KEY = 'height_in'.freeze
    WEIGHT_KEY = :weight
    WEIGHT_UNIT_KEY = :unit
    AGE_KEY = :age
    FITS = %w(self_slim self_regular).freeze
    DEFAULT_FIT = :self_slim

    def self.call(*attrs)
      new(*attrs).call
    end

    def initialize(params)
      @profile = Profile.find_or_initialize_by(customer_id: params[:customer_id])
      @params = params
      @category_ids = Category.all.ids
    end

    def call
      return true if profile.persisted?

      assign_height
      assign_measurements
      assign_fits
      profile.custom_measured = true
      save!
      create_profile_categories
      update_customer
    end

    private

    attr_reader :params, :profile, :category_ids

    delegate :save!, to: :profile

    def assign_measurements
      params[:measurements].each do |key, value|
        category_param_names = MAPPINGS[key]
        next unless category_param_names

        category_param_names.each do |param_name|
          CategoryParam.by_param_name(param_name).find_each do |category_param|
            if category_param.param_digits?
              profile.measurements.build(value: value_or_converted_value(value, category_param.param_title), category_param_id: category_param.id)
            else
              profile.measurements.build(category_param_value_id: resolve_value(category_param, value),
                                         category_param_id: category_param.id)
            end
          end
        end
      end
    end

    def resolve_value(category_param, value)
      if category_param.param_title.in? SHOULDER_SLOPES
        category_param.values.find_by_title(SHOULDER_SLOPE_MAPPINGS[value]).id
      else
        category_param.values.find_by_title(value)&.id
      end
    end

    def assign_fits
      category_ids.each do |category_id|
        profile.fits.build(fit: resolve_fit, category_id: category_id, checked: true, submitted: false)
      end
    end

    def resolve_fit
      params[:fit].in?(FITS) ? params[:fit] : DEFAULT_FIT
    end

    def assign_height
      inches_category_param = CategoryParam.by_param_name(HEIGHT_IN_NAME).first
      cms_category_param = CategoryParam.by_param_name(HEIGHT_CM_NAME).first
      if measurements_in_cms?
        value = params[:measurements][HEIGHT_CM_KEY].to_f

        profile.measurements.build(value: value.fdiv(INCHES_DIVIDER).round(ROUND_VALUE), category_param_id: inches_category_param.id)
        profile.measurements.build(value: value, category_param_id: cms_category_param.id)
      else
        value = params[:measurements][HEIGHT_IN_KEY].to_f

        profile.measurements.build(value: value, category_param_id: inches_category_param.id)
        profile.measurements.build(value: (value * INCHES_DIVIDER).round(ROUND_VALUE), category_param_id: cms_category_param.id)
      end
    end

    def create_profile_categories
      ProfileCategories::CRUD.new(profile_id: profile.id, category_ids: category_ids).create(status: 'to_be_submitted')
    end

    def update_customer
      profile.customer.update(weight: params[WEIGHT_KEY],
                              weight_unit: params[WEIGHT_UNIT_KEY],
                              age: params[AGE_KEY])
    end

    def value_or_converted_value(value, param_name)
      if measurements_in_cms?
        value.to_f.fdiv(INCHES_DIVIDER).round(ROUND_VALUE)
      else
        value.to_f
      end
    end

    def measurements_in_cms?
      params[:measurement_values_type] == CMS
    end
  end
end
