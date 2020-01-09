task create_profile_categories: :environment do
  categories = Category.all.select(:id, :name)
  batch_size = 50
  0.step(Profile.count, batch_size).each do |offset|
    profile_categories = []
    Profile.includes(:customer, measurements: [:category_param]).all.offset(offset).limit(batch_size).each do |profile|
      customer = profile.customer.decorate
      categories.each do |category|
        status = customer.old_category_status(category: category.name)[:status]
        next if status == 'n/a'
        status = ProfileCategory.statuses[status.to_sym]
        profile_categories << ProfileCategory.new(profile_id: profile.id, category_id: category.id, status: status)
      end
    end
    ProfileCategory.import profile_categories

    puts "Done #{offset} profiles!"
    puts "Imported #{profile_categories.count} profile categories!"
  end
end

# previously method old_category_status lived in class CustomerDecorator; end
# now moved here as a part of history
# TODO: check if this rake task might be used, otherwise delete it

# def old_category_status(category:)
#   return { status: 'n/a', class: 'label label-default' } unless profile
#   measurements = profile.measurements.select { |measurement| measurement.category_name == category }
#   case
#     when measurements.empty? then { status: 'n/a', class: 'label label-default' }
#     when measurements.first.submitted then { status: 'submitted', class: 'label label-success' }
#     else { status: 'saved', class: 'label label-warning' }
#   end
# end
