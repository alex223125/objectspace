json.extract! simple_object, :id, :title, :description, :created_at, :updated_at
json.url simple_object_url(simple_object, format: :json)
