task change_category_order: :environment do
  Category.all.each do |category|
    order = category.id + 1
    order = 1 if category.id == 8
    category.update_attribute(:order, order)
  end
end