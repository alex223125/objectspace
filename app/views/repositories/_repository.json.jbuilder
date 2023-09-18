json.extract! repository, :id, :title, :description, :is_public, :created_at, :updated_at
json.url repository_url(repository, format: :json)
