json.array!(@alteration_services) do |service|
  json.id           service.name
  json.text         service.name
end
