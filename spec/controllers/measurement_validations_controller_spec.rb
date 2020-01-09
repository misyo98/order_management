# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeasurementValidationsController, type: :controller do
  describe 'POST #create_validation_copy' do
    let!(:category) { create :category, name: 'New Category' }
    let!(:category_param) { create :category_param, category: category }
    let!(:category_param2) { create :category_param, category: category }
    let!(:validation) { create :measurement_validation, category_param: category_param }
    let(:user) { create :user }

    before { sign_in user }

    it 'create copy of validation rule for selected category param' do
      expect(MeasurementValidation.count).to eq 1

      expect { post :create_validation_copy, id: validation.id, category_param_id: category_param.id, measurement: category_param2.id, format: :js }
        .to change { MeasurementValidation.count }.by 1

      copied_validation = MeasurementValidation.last
      expect(copied_validation.category_param_id).to eq category_param2.id
      expect(copied_validation.comment).to eq "#{validation.comment} - Copy 1"
    end
  end
end
