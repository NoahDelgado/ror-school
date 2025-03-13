json.extract! status, :id, :slug, :title, :created_at, :updated_at
json.url status_url(status, format: :json)
