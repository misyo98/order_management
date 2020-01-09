require 'rails_helper'

RSpec.describe LineItemsHelper, type: :helper do
  describe '#input_by_key' do
    subject { helper.input_by_key(key) }

    context 'select key' do
      let(:key) { :courier_company }

      it { is_expected.to eq '<select name="courier_company_id" id="courier_company_id" class="form-control"></select>' }
    end

    context 'text key' do
      let(:key) { :manufacturer_order_number }

      it { is_expected.to eq '<input type="text" name="m_order_number" id="m_order_number" class="form-control" />' }
    end

    context 'key is not from the list' do
      let(:key) { :some_unexpected_key }

      it { is_expected.to eq '<input type="text" name="some_unexpected_key" id="some_unexpected_key" class="form-control" />' }
    end
  end
end
