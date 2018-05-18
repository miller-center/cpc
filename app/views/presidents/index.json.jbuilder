json.array!(@presidents) do |president|
  json.extract! president, :id
  json.url president_url(president, format: :json)
end
