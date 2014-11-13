json.array!(@notes) do |note|
  json.extract! note, :id, :title, :body_text, :body_html, :created_at, :updated_at
  json.url api_v1_note_url(note, format: :json, api_key: current_user.api_key)
end