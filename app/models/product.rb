class Product < ActiveRecord::Base
  CATEGORIES = ['MADE-TO-MEASURE SUITS', 'MADE-TO-MEASURE SHIRTS', 'MADE-TO-MEASURE CHINOS',
                'MADE-TO-MEASURE TROUSERS', 'MADE-TO-MEASURE WAISTCOATS', 'MADE-TO-MEASURE JACKETS',
                'MADE-TO-MEASURE OVERCOATS', 'GIFT CARD', 'VOUCHERS', 'POSTAGE', 'ACCESSORIES', 'NON-CUSTOM',
                'ALTERATION', 'SHIPPING', 'EXTRA AMOUNT'].freeze
  SUIT_CATEGORY = 'MADE-TO-MEASURE SUITS'.freeze
  REMAKE_TROUSERS_TITLE = 'Trousers Remake'.freeze
  REMAKE_JACKET_TITLE = 'Jacket Remake'.freeze

  def self.remake_trousers
    find_by(title: REMAKE_TROUSERS_TITLE)
  end

  def self.remake_jacket
    find_by(title: REMAKE_JACKET_TITLE)
  end

  def suit?
    category == SUIT_CATEGORY
  end
end
