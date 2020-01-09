json.array!(@customers) do |customer|
  json.id               customer.email
  json.text             customer.name_for_select
end
