json.extract! room, :id, :name, :created_at, :updated_at
json.members do
  json.array!(room.members) do |member|
    json.extract! member, :id, :email, :name, :created_at, :updated_at
  end
end
json.url room_url(room, format: :json)
