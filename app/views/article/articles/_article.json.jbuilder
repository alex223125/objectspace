json.extract! article, :id, :title, :default_version_id, :visibility_status, :source_page_description, :created_at, :updated_at
json.url article_url(article, format: :json)
