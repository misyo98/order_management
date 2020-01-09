json.array!(@tags) do |tag|
  json.id               tag.name
  json.text             tag.name
end
