# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customers::ProfileCreator do
  let(:jacket_c) { create(:category, name: 'Jacket') }
  let(:pants_c) { create(:category, name: 'Pants') }
  let(:shirt_c) { create(:category, name: 'Shirt') }
  let(:waistcoat_c) { create(:category, name: 'Waistcoat') }
  let(:chinos_c) { create(:category, name: 'Chinos') }
  let(:body_type_c) { create(:category, name: 'Body shape & postures') }
  let(:height_c) { create(:category, name: 'Height') }
  let(:neck_p) { create(:param, title: 'Neck', input_type: :digits) }
  let(:chest_p) { create(:param, title: 'Chest', input_type: :digits) }
  let(:waistcoat_chest_p) { create(:param, title: 'Waistcoat Chest', input_type: :digits) }
  let(:waist_button_pos) { create(:param, title: 'Waist (Button Position)', input_type: :digits) }
  let(:waist_belly_button_pos) { create(:param, title: 'Waist (Belly Button)', input_type: :digits) }
  let(:hip_w_pleats) { create(:param, title: 'Hip - Pants - With pleats', input_type: :digits) }
  let(:hip_no_pleats) { create(:param, title: 'Hip - Pants - No pleats', input_type: :digits) }
  let(:hip) { create(:param, title: 'Hip', input_type: :digits) }
  let(:shoulder) { create(:param, title: 'Shoulder', input_type: :digits) }
  let(:s_sleeve_length_l) { create(:param, title: 'Shirt Sleeve Length (left sleeve)', input_type: :digits) }
  let(:s_sleeve_length_r) { create(:param, title: 'Shirt Sleeve Length (right sleeve)', input_type: :digits) }
  let(:j_sleeve_length_l) { create(:param, title: 'Jacket Sleeve Length (left sleeve)', input_type: :digits) }
  let(:j_sleeve_length_r) { create(:param, title: 'Jacket Sleeve Length (right sleeve)', input_type: :digits) }
  let(:fr_cuff_w_watch) { create(:param, title: 'Wrist / Cuff - French cuff - with watch', input_type: :digits) }
  let(:fr_cuff_wo_watch) { create(:param, title: 'Wrist / Cuff - French cuff - without watch', input_type: :digits) }
  let(:bt_cuff_w_watch) { create(:param, title: 'Wrist / Cuff - Button cuff - with watch', input_type: :digits) }
  let(:bt_cuff_wo_watch) { create(:param, title: 'Wrist / Cuff - Button cuff - without watch', input_type: :digits) }
  let(:wrist_cuff) { create(:param, title: 'Wrist / Cuff', input_type: :digits) }
  let(:biceps) { create(:param, title: 'Biceps', input_type: :digits) }
  let(:s_lnght_b_tuck_out) { create(:param, title: 'Shirt length (back) - Tuck-in', input_type: :digits) }
  let(:s_lnght_f_tuck_out) { create(:param, title: 'Shirt length (front) - Tuck-out', input_type: :digits) }
  let(:s_lnght_b_tuck_in) { create(:param, title: 'Shirt length (back) - Tuck-in', input_type: :digits) }
  let(:s_lnght_f_tuck_in) { create(:param, title: 'Shirt Length (front) - Tuck-in', input_type: :digits) }
  let(:wstc_first_bt) { create(:param, title: 'Waistcoat 1st Button Position', input_type: :digits) }
  let(:wstc_bck_lngth) { create(:param, title: 'Waistcoat Back Length', input_type: :digits) }
  let(:wstc_frnt_lngth_s) { create(:param, title: 'Waistcoat Front Length (straight)', input_type: :digits) }
  let(:wstc_frnt_lngth_p) { create(:param, title: 'Waistcoat Front Length (pointed)', input_type: :digits) }
  let(:btn_pstn_one) { create(:param, title: 'Button position - 1 buttons', input_type: :digits) }
  let(:btn_pstn_two) { create(:param, title: 'Button position - 2 buttons', input_type: :digits) }
  let(:jck_lngth_b) { create(:param, title: 'Jacket Length (back)', input_type: :digits) }
  let(:jck_lngth_fr) { create(:param, title: 'Jacket Length (front)', input_type: :digits) }
  let(:pant_waist) { create(:param, title: 'Pant Waist', input_type: :digits) }
  let(:rise) { create(:param, title: 'Rise', input_type: :digits) }
  let(:thigh) { create(:param, title: 'Thigh', input_type: :digits) }
  let(:knee) { create(:param, title: 'Knee', input_type: :digits) }
  let(:pant_cuff) { create(:param, title: 'Pant cuff', input_type: :digits) }
  let(:calf) { create(:param, title: 'Calf', input_type: :digits) }
  let(:pant_lngth_out_r_l) { create(:param, title: 'Pant length (outseam right leg)', input_type: :digits) }
  let(:pant_lngth_out_l_l) { create(:param, title: 'Pant length (outseam left leg)', input_type: :digits) }
  let(:height_cm) { create(:param, title: 'Height (cm)', input_type: :digits) }
  let(:height_inches) { create(:param, title: 'Height (inches)', input_type: :digits) }
  let(:body_type) { create(:param, title: 'Body type', input_type: :values) }
  let(:front_shoulder) { create(:param, title: 'Front Shoulder', input_type: :values) }
  let(:shoulder_slope_l) { create(:param, title: 'Shoulder slope - Left', input_type: :values) }
  let(:shoulder_slope_r) { create(:param, title: 'Shoulder slope - Right', input_type: :values) }
  let(:prominent_chest) { create(:param, title: 'Prominent Chest?', input_type: :values) }

  let(:body_type_value) { create(:value, title: 'Average') }
  let(:front_shoulder_value) { create(:value, title: 'Slight Backwards') }
  let(:shoulder_slope_value) { create(:value, title: 'E') }
  let(:prominent_chest_value) { create(:value, title: 'Very Prominent Chest') }

  let!(:neck_s) { create(:category_param, category: jacket_c, param: neck_p) }
  let!(:neck_j) { create(:category_param, category: shirt_c, param: neck_p) }

  let!(:chest_j) { create(:category_param, category: jacket_c, param: chest_p) }
  let!(:chest_s) { create(:category_param, category: shirt_c, param: chest_p) }
  let!(:chest_wc) { create(:category_param, category: waistcoat_c, param: waistcoat_chest_p) }

  let!(:waist_but_s) { create(:category_param, category: shirt_c, param: waist_button_pos) }
  let!(:waist_but_j) { create(:category_param, category: jacket_c, param: waist_button_pos) }
  let!(:waist_but_wc) { create(:category_param, category: waistcoat_c, param: waist_button_pos) }

  let!(:waist_bel_but_s) { create(:category_param, category: shirt_c, param: waist_belly_button_pos) }
  let!(:waist_bel_but_j) { create(:category_param, category: jacket_c, param: waist_belly_button_pos) }
  let!(:waist_bel_but_wc) { create(:category_param, category: waistcoat_c, param: waist_belly_button_pos) }

  let!(:hip_pleats_ch) { create(:category_param, category: chinos_c, param: hip_w_pleats) }
  let!(:hip_pleats_p) { create(:category_param, category: pants_c, param: hip_w_pleats) }
  let!(:hip_no_pleats_ch) { create(:category_param, category: chinos_c, param: hip_no_pleats) }
  let!(:hip_no_pleats_p) { create(:category_param, category: pants_c, param: hip_no_pleats) }
  let!(:hip_s) { create(:category_param, category: shirt_c, param: hip) }
  let!(:hip_j) { create(:category_param, category: jacket_c, param: hip) }

  let!(:shoulder_s) { create(:category_param, category: shirt_c, param: shoulder) }
  let!(:shoulder_j) { create(:category_param, category: jacket_c, param: shoulder) }

  let!(:sleeve_r_s) { create(:category_param, category: shirt_c, param: s_sleeve_length_r) }
  let!(:sleeve_l_s) { create(:category_param, category: shirt_c, param: s_sleeve_length_l) }
  let!(:sleeve_r_j) { create(:category_param, category: jacket_c, param: j_sleeve_length_r) }
  let!(:sleeve_l_j) { create(:category_param, category: jacket_c, param: j_sleeve_length_l) }

  let!(:fr_cuff_w_watch_s) { create(:category_param, category: shirt_c, param: fr_cuff_w_watch) }
  let!(:fr_cuff_wo_watch_s) { create(:category_param, category: shirt_c, param: fr_cuff_wo_watch) }
  let!(:bt_cuff_w_watch_s) { create(:category_param, category: shirt_c, param: bt_cuff_w_watch) }
  let!(:bt_cuff_wo_watch_s) { create(:category_param, category: shirt_c, param: bt_cuff_wo_watch) }
  let!(:wrist_cuff_j) { create(:category_param, category: jacket_c, param: wrist_cuff) }

  let!(:biceps_s) { create(:category_param, category: shirt_c, param: biceps) }
  let!(:biceps_j) { create(:category_param, category: jacket_c, param: biceps) }

  let!(:s_lnght_b_tuck_out_s) { create(:category_param, category: shirt_c, param: s_lnght_b_tuck_out) }
  let!(:s_lnght_f_tuck_out_s) { create(:category_param, category: shirt_c, param: s_lnght_f_tuck_out) }
  let!(:s_lnght_b_tuck_in_s) { create(:category_param, category: shirt_c, param: s_lnght_b_tuck_in) }
  let!(:s_lnght_f_tuck_in_s) { create(:category_param, category: shirt_c, param: s_lnght_f_tuck_in) }

  let!(:wstc_first_bt_w) { create(:category_param, category: waistcoat_c, param: wstc_first_bt) }
  let!(:wstc_bck_lngth_w) { create(:category_param, category: waistcoat_c, param: wstc_bck_lngth) }
  let!(:wstc_frnt_lngth_s_w) { create(:category_param, category: waistcoat_c, param: wstc_frnt_lngth_s) }
  let!(:wstc_frnt_lngth_p_w) { create(:category_param, category: waistcoat_c, param: wstc_frnt_lngth_p) }

  let!(:btn_pstn_one_j) { create(:category_param, category: jacket_c, param: btn_pstn_one) }
  let!(:btn_pstn_two_j) { create(:category_param, category: jacket_c, param: btn_pstn_two) }
  let!(:jck_lngth_b_j) { create(:category_param, category: jacket_c, param: jck_lngth_b) }
  let!(:jck_lngth_b_j) { create(:category_param, category: jacket_c, param: jck_lngth_b) }

  let!(:pant_waist_ch) { create(:category_param, category: chinos_c, param: pant_waist) }
  let!(:pant_waist_p) { create(:category_param, category: pants_c, param: pant_waist) }

  let!(:rise_ch) { create(:category_param, category: chinos_c, param: rise) }
  let!(:rise_p) { create(:category_param, category: pants_c, param: rise) }

  let!(:thigh_ch) { create(:category_param, category: chinos_c, param: thigh) }
  let!(:thigh_p) { create(:category_param, category: pants_c, param: thigh) }

  let!(:knee_ch) { create(:category_param, category: chinos_c, param: knee) }
  let!(:knee_p) { create(:category_param, category: pants_c, param: knee) }

  let!(:pant_cuff_ch) { create(:category_param, category: chinos_c, param: pant_cuff) }
  let!(:pant_cuff_p) { create(:category_param, category: pants_c, param: pant_cuff) }

  let!(:calf_ch) { create(:category_param, category: chinos_c, param: calf) }
  let!(:calf_p) { create(:category_param, category: pants_c, param: calf) }

  let!(:pant_lngth_out_r_l_ch) { create(:category_param, category: chinos_c, param: pant_lngth_out_r_l) }
  let!(:pant_lngth_out_r_l_p) { create(:category_param, category: pants_c, param: pant_lngth_out_r_l) }

  let!(:pant_lngth_out_l_l_ch) { create(:category_param, category: chinos_c, param: pant_lngth_out_l_l) }
  let!(:pant_lngth_out_l_l_p) { create(:category_param, category: pants_c, param: pant_lngth_out_l_l) }

  let!(:height_in_h) { create(:category_param, category: height_c, param: height_inches) }
  let!(:height_cm_h) { create(:category_param, category: height_c, param: height_cm) }

  let!(:body_type_b) { create(:category_param, category: body_type_c, param: body_type) }
  let!(:front_shoulder_b) { create(:category_param, category: body_type_c, param: front_shoulder) }
  let!(:shoulder_slope_l_b) { create(:category_param, category: body_type_c, param: shoulder_slope_l) }
  let!(:shoulder_slope_r_b) { create(:category_param, category: body_type_c, param: shoulder_slope_r) }
  let!(:prominent_chest_b) { create(:category_param, category: body_type_c, param: prominent_chest) }

  let!(:body_type_v) { create(:category_param_value, category_param: body_type_b, value: body_type_value) }
  let!(:front_shoulder_v) { create(:category_param_value, category_param: front_shoulder_b, value: front_shoulder_value) }
  let!(:shoulder_slope_l_v) { create(:category_param_value, category_param: shoulder_slope_l_b, value: shoulder_slope_value) }
  let!(:shoulder_slope_r_v) { create(:category_param_value, category_param: shoulder_slope_r_b, value: shoulder_slope_value) }
  let!(:prominent_chest_v) { create(:category_param_value, category_param: prominent_chest_b, value: prominent_chest_value) }

  let(:digits_params) { [neck_s, neck_j, chest_j, chest_s, chest_wc, waist_but_s, waist_but_j, waist_but_wc, waist_bel_but_s,
                         waist_bel_but_j, waist_bel_but_wc, hip_pleats_ch, hip_pleats_p, hip_no_pleats_ch, hip_no_pleats_p,
                         hip_s, hip_j, shoulder_s, shoulder_j, sleeve_r_s, sleeve_l_s, sleeve_r_j, sleeve_l_j, fr_cuff_w_watch_s,
                         fr_cuff_wo_watch_s, bt_cuff_w_watch_s, bt_cuff_wo_watch_s, wrist_cuff_j, biceps_s, biceps_j,
                         s_lnght_b_tuck_out_s, s_lnght_f_tuck_out_s, s_lnght_b_tuck_in_s, s_lnght_f_tuck_in_s, wstc_first_bt_w,
                         wstc_bck_lngth_w, wstc_frnt_lngth_s_w, wstc_frnt_lngth_p_w, btn_pstn_one_j, btn_pstn_two_j,
                         jck_lngth_b_j, jck_lngth_b_j, pant_waist_ch, pant_waist_p, rise_ch, rise_p, thigh_ch, thigh_p,
                         knee_ch, knee_p, pant_cuff_ch, pant_cuff_p, calf_ch, calf_p, pant_lngth_out_r_l_ch,
                         pant_lngth_out_r_l_p, pant_lngth_out_l_l_ch, pant_lngth_out_l_l_p] }
  let(:customer) { create :customer }
  let(:params) do
    { customer_id: customer.id, measurements: measurements, fit: 'self_regular', measurement_values_type: 'inches', weight: '76', unit: 'kg', age: '33' }
  end
  let(:measurements) do
    {
      'height_cm'       => '',
      'height_in'       => 66.93,
      'neck'            => 37,
      'chest'           => 23.5,
      'upper_waist'     => 12.6,
      'lower_waist'     => 13.2,
      'hip'             => 34.2,
      'shoulder'        => 12.1,
      'sleeve_length'   => 27.15,
      'wrist'           => 28.15,
      'bicep'           => 29.15,
      'front_length'    => 30.15,
      'pant_waist'      => 31.15,
      'rise'            => 32.15,
      'thigh'           => 33.15,
      'knee'            => 34.15,
      'calf'            => 35.15,
      'pants_length'    => 36.15,
      'body_type'       => 'Average',
      'front_shoulder'  => 'Slight Backwards',
      'shoulder_slope'  => 'High',
      'prominent_chest' => 'Very Prominent Chest'
    }
  end

  subject { described_class.(params) }

  it 'maps values correctly and saves them' do
    subject
    customer.reload

    digits_params.each do |category_param|
      mapping_key = described_class::MAPPINGS.find { |key, param_names| category_param.param_title.in? param_names }.first

      expect(customer.profile.measurements.find_by(category_param_id: category_param.id).value).to eq measurements[mapping_key]
    end

    expect(customer.profile.measurements.find_by(category_param_id: body_type_b.id).category_param_value).to eq body_type_v
    expect(customer.profile.measurements.find_by(category_param_id: front_shoulder_b.id).category_param_value).to eq front_shoulder_v
    expect(customer.profile.measurements.find_by(category_param_id: shoulder_slope_l_b.id).category_param_value).to eq shoulder_slope_l_v
    expect(customer.profile.measurements.find_by(category_param_id: shoulder_slope_r_b.id).category_param_value).to eq shoulder_slope_r_v
    expect(customer.profile.measurements.find_by(category_param_id: prominent_chest_b.id).category_param_value).to eq prominent_chest_v
    expect(customer.profile.measurements.find_by(category_param_id: height_in_h.id).value).to eq BigDecimal.new('66.93')
    expect(customer.profile.measurements.find_by(category_param_id: height_cm_h.id).value).to eq 170

    expect(customer.profile.fits).not_to be_empty
    expect(customer.profile.fits.first.fit).to eq 'self_regular'
    expect(customer.profile.categories).not_to be_empty
    expect(customer.profile.custom_measured).to be true
    expect(customer.weight).to eq 76
    expect(customer.weight_unit).to eq 'kg'
    expect(customer.age).to eq 33
  end

  context 'measurements in cms' do
    let(:digits_params) { [neck_s, neck_j, chest_j, chest_s, chest_wc, waist_but_s, waist_but_j, waist_but_wc, waist_bel_but_s,
                           waist_bel_but_j, waist_bel_but_wc, hip_pleats_ch, hip_pleats_p, hip_no_pleats_ch, hip_no_pleats_p,
                           hip_s, hip_j, shoulder_s, shoulder_j, sleeve_r_s, sleeve_l_s, sleeve_r_j, sleeve_l_j, fr_cuff_w_watch_s,
                           fr_cuff_wo_watch_s, bt_cuff_w_watch_s, bt_cuff_wo_watch_s, wrist_cuff_j, biceps_s, biceps_j,
                           s_lnght_b_tuck_out_s, s_lnght_f_tuck_out_s, s_lnght_b_tuck_in_s, s_lnght_f_tuck_in_s, wstc_first_bt_w,
                           wstc_bck_lngth_w, wstc_frnt_lngth_s_w, wstc_frnt_lngth_p_w, btn_pstn_one_j, btn_pstn_two_j,
                           jck_lngth_b_j, jck_lngth_b_j, pant_waist_ch, pant_waist_p, rise_ch, rise_p, thigh_ch, thigh_p,
                           knee_ch, knee_p, pant_cuff_ch, pant_cuff_p, calf_ch, calf_p, pant_lngth_out_r_l_ch,
                           pant_lngth_out_r_l_p, pant_lngth_out_l_l_ch, pant_lngth_out_l_l_p] }
    let(:params) do
      { customer_id: customer.id, measurements: measurements, fit: 'self_slim', measurement_values_type: 'cm' }
    end
    let(:measurements) do
      {
        'height_cm'       => '170',
        'height_in'       => '',
        'neck'            => '120',
        'chest'           => '110',
        'upper_waist'     => '34',
        'lower_waist'     => '74.5',
        'hip'             => '45.7',
        'shoulder'        => '56.1',
        'sleeve_length'   => '32.15',
        'wrist'           => '45.15',
        'bicep'           => '67.15',
        'front_length'    => '68.15',
        'pant_waist'      => '69.15',
        'rise'            => '70.15',
        'thigh'           => '71.15',
        'knee'            => '72.15',
        'calf'            => '73.15',
        'pants_length'    => '74.15',
        'body_type'       => 'Average',
        'front_shoulder'  => 'Slight Backwards',
        'shoulder_slope'  => 'High',
        'prominent_chest' => 'Very Prominent Chest'
      }
    end

    it 'maps values correctly and saves them' do
      subject
      customer.reload

      digits_params.each do |category_param|
        mapping_key = described_class::MAPPINGS.find { |key, param_names| category_param.param_title.in? param_names }.first

        expect(customer.profile.measurements.find_by(category_param_id: category_param.id).value).to eq measurements[mapping_key].to_f.fdiv(2.54).round(2)
      end
      expect(customer.profile.measurements.find_by(category_param_id: height_in_h.id).value).to eq BigDecimal.new('66.93')
      expect(customer.profile.measurements.find_by(category_param_id: height_cm_h.id).value).to eq 170
      expect(customer.profile.fits.first.fit).to eq 'self_slim'
      expect(customer.weight).to be_nil
      expect(customer.weight_unit).to be_nil
      expect(customer.age).to be_nil
    end
  end
end
