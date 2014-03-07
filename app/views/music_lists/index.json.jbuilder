json.array!(@infos) do |info|
  json.extract! info, :id
  json.url info_url(info, format: :json)
end
