# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FabricEditorController, type: :controller do
  let(:fabric_category) { create :fabric_category, title: 'Fabric Category' }
  let(:user) { create :user }

  before { sign_in user }

  describe 'PATCH #create_fabric_group' do
    context 'whole new fabric customization objects' do
      let(:fabric_params) do
        {
          tuxedo: true,
          tuxedo_price: { 'GBP' => '5', 'SGD' => '4' },
          fabric_tabs_attributes: {
            '1' => {
              title: 'Fabric Tab 1',
              order: 1,
              fabric_options_attributes: {
                '1' => {
                  title: 'Fabric Option 1',
                  order: 1,
                  button_type: :dropdown_button,
                  placeholder: 'Some text',
                  outfitter_selection: :os_all,
                  tuxedo: :tuxedo_all,
                  premium: :premium_yes,
                  fusible: :fusible_no,
                  manufacturer: :new_m,
                  fabric_option_values_attributes: {
                    '1' => {
                      title: 'Fabric Option Value 1',
                      order: 1,
                      image_url: 'http://some_image.com',
                      price: { 'GBP' => '5', 'SGD' => '4' },
                      tuxedo: :tuxedo_yes,
                      premium: :premium_yes,
                      manufacturer: :all_m
                    },
                    '2' => {
                      title: 'Fabric Option Value 2',
                      order: 2,
                      image_url: 'http://another_image.com',
                      price: { 'GBP' => '10', 'SGD' => '5' },
                      tuxedo: :tuxedo_all,
                      premium: :premium_all,
                      manufacturer: :new_m
                    }
                  }
                }
              }
            },
            '2' => {
              title: 'Fabric Tab 2',
              order: 2,
              fabric_options_attributes: {
                '1' => {
                  title: 'Fabric Option 2',
                  order: 1,
                  button_type: :radio_button,
                  placeholder: 'Another text',
                  outfitter_selection: :os_no,
                  tuxedo: :tuxedo_no,
                  premium: :premium_all,
                  fusible: :fusible_yes,
                  manufacturer: :old_m
                },
                '2' => {
                  title: 'Fabric Option 3',
                  order: 2,
                  button_type: :checkbox_button,
                  placeholder: 'And another one',
                  outfitter_selection: :os_yes,
                  tuxedo: :tuxedo_yes,
                  premium: :premium_no,
                  fusible: :fusible_all,
                  manufacturer: :new_m
                }
              }
            }
          }
        }
      end

      it 'creates new fabric objects' do
        patch :create_fabric_group, id: fabric_category.id, fabric_category: fabric_params, format: :js

        fabric_category.reload
        first_tab = fabric_category.fabric_tabs.first
        second_tab = fabric_category.fabric_tabs.second

        expect(fabric_category.tuxedo).to be true
        expect(fabric_category.tuxedo_price).to eq({'GBP' => '5', 'SGD' => '4'})
        expect(fabric_category.fabric_tabs.count).to eq 2
        expect(first_tab.fabric_options.count).to eq 1
        expect(first_tab.fabric_options.first.fabric_option_values.count).to eq 2
        expect(first_tab.fabric_options.first.fabric_option_values.first.title).to eq 'Fabric Option Value 1'
        expect(first_tab.fabric_options.first.fabric_option_values.first.price).to eq({'GBP' => '5', 'SGD' => '4'})
        expect(first_tab.fabric_options.first.fabric_option_values.second.title).to eq 'Fabric Option Value 2'
        expect(first_tab.fabric_options.first.fabric_option_values.second.price).to eq({'GBP' => '10', 'SGD' => '5'})
        expect(second_tab.fabric_options.count).to eq 2
        expect(second_tab.fabric_options.first.title).to eq 'Fabric Option 2'
        expect(second_tab.fabric_options.second.title).to eq 'Fabric Option 3'
      end
    end

    context 'existing fabric customization object' do
      let!(:fabric_tab_1) { create :fabric_tab, fabric_category: fabric_category, title: 'Fabric Tab 1', order: 1 }
      let!(:fabric_tab_2) { create :fabric_tab, fabric_category: fabric_category, title: 'Fabric Tab 2', order: 2 }
      let!(:fabric_option_1) do
        create :fabric_option, fabric_tab: fabric_tab_1, title: 'Fabric Option 1', order: 1, button_type: :radio_button,
                               placeholder: 'Another text', outfitter_selection: :os_no, tuxedo: :tuxedo_no,
                               premium: :premium_no, fusible: :fusible_no, manufacturer: :old_m
      end
      let!(:fabric_option_2) do
        create :fabric_option, fabric_tab: fabric_tab_2, title: 'Fabric Option 2', order: 1, button_type: :dropdown_button,
                               placeholder: 'Some text', outfitter_selection: :os_yes, tuxedo: :tuxedo_yes,
                               premium: :premium_yes, fusible: :fusible_yes, manufacturer: :new_m
      end
      let!(:fabric_option_3) do
        create :fabric_option, fabric_tab: fabric_tab_2, title: 'Fabric Option 3', order: 2, button_type: :checkbox_button,
                               placeholder: 'New text', outfitter_selection: :os_no, tuxedo: :tuxedo_yes,
                               premium: :premium_no, fusible: :fusible_all, manufacturer: :new_m
      end
      let!(:fabric_option_value_1) do
        create :fabric_option_value, fabric_option: fabric_option_1, title: 'Fabric Option Value 1', order: 1, price: {SGD: 10},
                                     image_url: 'http://some_image.com', premium: :premium_all, manufacturer: :all_m
      end
      let!(:fabric_option_value_2) do
        create :fabric_option_value, fabric_option: fabric_option_2, title: 'Fabric Option Value 2', order: 1, price: {GBP: 15},
                                     image_url: 'http://another_image.com', premium: :premium_yes, manufacturer: :new_m
      end
      let!(:fabric_option_value_3) do
        create :fabric_option_value, fabric_option: fabric_option_3, title: 'Fabric Option Value 3', order: 2, price: {GBP: 5},
                                     image_url: 'http://and_another_image.com', premium: :premium_no, manufacturer: :old_m
      end
      let(:fabric_params) do
        {
          tuxedo: true,
          tuxedo_price: { 'GBP' => '5', 'SGD' => '4' },
          fabric_tabs_attributes: {
            '1' => {
              id: fabric_tab_1.id,
              title: 'Updated Fabric Tab 1',
              order: 2,
              fabric_options_attributes: {
                '1' => {
                  id: fabric_option_1.id,
                  title: 'Updated Fabric Option 1',
                  button_type: :checkbox_button,
                  placeholder: 'Some new text',
                  outfitter_selection: :os_all,
                  tuxedo: :tuxedo_all,
                  premium: :premium_all,
                  fusible: :fusible_all,
                  manufacturer: :all_m,
                  fabric_option_values_attributes: {
                    '1' => {
                      id: fabric_option_value_1.id,
                      title: 'Updated Fabric Option Value 1',
                      image_url: 'http://another_image.com',
                      price: { GBP: '10', SGD: '15' },
                      premium: :premium_yes,
                      manufacturer: :all_m
                    }
                  }
                }
              }
            },
            '2' => {
              id: fabric_tab_2.id,
              title: 'Updated Fabric Tab 2',
              order: 1,
              fabric_options_attributes: {
                '1' => {
                  id: fabric_option_2.id,
                  title: 'Updated Fabric Option 2',
                  button_type: :radio_button,
                  placeholder: 'Another text',
                  outfitter_selection: :os_no,
                  tuxedo: :tuxedo_no,
                  premium: :premium_all,
                  fusible: :fusible_yes,
                  manufacturer: :old_m,
                  fabric_option_values_attributes: {
                    '1' => {
                      id: fabric_option_value_2.id,
                      title: 'Updated Fabric Option Value 2',
                      image_url: 'http://and_another_image.com',
                      price: { GBP: '25', SGD: '30' },
                      premium: :premium_no,
                      manufacturer: :old_m
                    }
                  }
                }
              }
            }
          }
        }
      end

      it 'updates existing fabric customization objects' do
        expect(fabric_category.tuxedo).to be nil
        expect(fabric_category.tuxedo_price).to be nil
        expect(fabric_category.fabric_tabs.count).to eq 2
        expect(fabric_tab_1.fabric_options.count).to eq 1
        expect(fabric_tab_2.fabric_options.count).to eq 2
        expect(fabric_option_1.fabric_option_values.count).to eq 1
        expect(fabric_option_2.fabric_option_values.count).to eq 1

        patch :create_fabric_group, id: fabric_category.id, fabric_category: fabric_params, format: :js

        [fabric_category, fabric_tab_1, fabric_tab_2, fabric_option_1, fabric_option_2, fabric_option_value_1, fabric_option_value_2]
          .each(&:reload)

        expect(fabric_category.tuxedo).to be true
        expect(fabric_category.tuxedo_price).to eq({'GBP' => '5', 'SGD' => '4'})
        expect(fabric_category.fabric_tabs.count).to eq 2
        expect(fabric_tab_1.fabric_options.count).to eq 1
        expect(fabric_tab_2.fabric_options.count).to eq 2

        expect(
            [fabric_option_1.title, fabric_option_1.button_type, fabric_option_1.placeholder, fabric_option_1.outfitter_selection,
              fabric_option_1.tuxedo, fabric_option_1.premium, fabric_option_1.fusible, fabric_option_1.manufacturer
            ]
          ).to match_array(
            ['Updated Fabric Option 1', 'checkbox_button', 'Some new text', 'os_all', 'tuxedo_all',
             'premium_all', 'fusible_all', 'all_m'
            ]
        )
        expect(
            [fabric_option_2.title, fabric_option_2.button_type, fabric_option_2.placeholder, fabric_option_2.outfitter_selection,
              fabric_option_2.tuxedo, fabric_option_2.premium, fabric_option_2.fusible, fabric_option_2.manufacturer
            ]
          ).to match_array(
            ['Updated Fabric Option 2', 'radio_button', 'Another text', 'os_no', 'tuxedo_no',
             'premium_all', 'fusible_yes', 'old_m'
            ]
        )

        expect(
            [fabric_option_value_1.title, fabric_option_value_1.image_url, fabric_option_value_1.price, fabric_option_value_1.premium,
              fabric_option_value_1.manufacturer
            ]
          ).to match_array(['Updated Fabric Option Value 1', 'http://another_image.com', {'GBP' => '10', 'SGD' => '15'}, 'premium_yes', 'all_m']
        )
        expect(
            [fabric_option_value_2.title, fabric_option_value_2.image_url, fabric_option_value_2.price, fabric_option_value_2.premium,
              fabric_option_value_2.manufacturer
            ]
          ).to match_array(['Updated Fabric Option Value 2', 'http://and_another_image.com', {'GBP' => '25', 'SGD' => '30'}, 'premium_no', 'old_m']
        )
      end

      it 'removes marked fabric customization objects' do
        expect(fabric_category.fabric_tabs.count).to eq 2

        patch :create_fabric_group, id: fabric_category.id,
          fabric_category: {
            fabric_tabs_attributes: {
              '1' => {
                id: fabric_tab_1.id,
                _destroy: 1
              },
              '2' => {
                id: fabric_tab_2.id,
                fabric_options_attributes: {
                  '1' => {
                    id: fabric_option_2.id,
                    _destroy: 1
                  },
                  '2' => {
                    id: fabric_option_3.id,
                    fabric_option_values_attributes: {
                      '1' => {
                        id: fabric_option_value_3.id,
                        _destroy: 1
                      }
                    }
                  }
                }
              }
            }
          }, format: :js

        fabric_category.reload

        expect(fabric_category.fabric_tabs.count).to eq 1
        expect(fabric_tab_2.fabric_options).not_to be_empty
        expect(fabric_option_3.fabric_option_values).to be_empty
        expect(fabric_option_3.fabric_option_values).to be_empty
      end
    end
  end
end
