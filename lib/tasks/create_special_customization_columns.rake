desc 'Create special customizations columns for all line_item_scopes in Orders page'
task create_special_customizations_columns: :environment do
  LineItemScope.find_each do |scope|
    scope.columns.create(name: 'special_customizations_field', label: 'Special Customizations', order: 123)
  end
  puts 'Created special customizations columns'
end
