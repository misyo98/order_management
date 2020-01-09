json.array!(@customers) do |customer|
  json.id               customer.id
  json.text             customer.name_for_select
end
