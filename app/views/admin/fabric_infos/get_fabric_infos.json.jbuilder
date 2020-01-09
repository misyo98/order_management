json.array!(@fabric_infos) do |info|
  json.id               info.id
  json.text             info.fabric_code
end
