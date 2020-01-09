json.sales_locations do
  json.array!(@sales_locations) do |sales_location|
    json.id   sales_location.id
    json.name sales_location.name
  end
end
