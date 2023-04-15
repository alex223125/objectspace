json.extract! article_version, :id, :title, :solves_the_problem, :content, :sources, :additional_information, :created_at, :updated_at
json.url article_version_url(article_version, format: :json)
