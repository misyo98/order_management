# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Woocommerce::Helpers do
  let(:test_instance) { Class.new { include Woocommerce::Helpers }.new }

  describe '#product_params' do
    let(:api_params) { build :woocommerce_product, categories: ['super fine suits', 'bla', 'other category'] }
    let(:result) do
      {
        id:             1,
        title:          'New Product',
        type_product:   'simple',
        status:         'publish',
        permalink:      'exmaplehost.dot.com',
        sku:            'ES_1',
        price:          119.0,
        regular_price:  119.0,
        sale_price:     nil,
        total_sales:    666,
        category:       'MADE-TO-MEASURE SUITS',
        created_at:     Date.yesterday,
        updated_at:     Date.today
      }
    end

    subject { test_instance.product_params(params: api_params) }

    it { is_expected.to eq result }

    context 'non-suits category' do
      let(:api_params) { build :woocommerce_product, categories: ['ACCESSORIES', 'bla', 'other category'] }

      it { is_expected.to eq result.merge(category: 'ACCESSORIES') }
    end

    context 'downcased api product categories' do
      let(:api_params) { build :woocommerce_product, categories: ['Made-to-Measure Shirts and stuff', 'bla', 'other category'] }

      it { is_expected.to eq result.merge(category: 'MADE-TO-MEASURE SHIRTS') }
    end

    context 'when api category does not match any local product category' do
      let(:api_params) { build :woocommerce_product, categories: ['Made-to-Measure Nazar', 'bla', 'other category'] }

      it { is_expected.to eq result.merge(category: 'NON-CUSTOM') }
    end
  end
end
