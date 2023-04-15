# Searchkick.client = Elasticsearch::Client.new(hosts: ["localhost:9200"],
#                                               retry_on_failure: true,
#                                               transport_options: {request: {timeout: 250}})

# Elasticsearch::Model.client = Elasticsearch::Client.new url: env['RAILS_ENV']
# Searchkick.client = Elasticsearch::Client.new(hosts: env['RAILS_ENV'], retry_on_failure: true, transport_options: {request: {timeout: 250} })

# if Rails.env == "production"
#   url = 'http://myelasticsearch-xyz-foobar.amazonaws.com'
#   Elasticsearch::Model.client = Elasticsearch::Client.new url: url
#   Searchkick.client = Elasticsearch::Client.new(hosts: url, retry_on_failure: true, transport_options: {request: {timeout: 250}})
# else
#   url = 'http://localhost:9200/'
#   Elasticsearch::Model.client = Elasticsearch::Client.new url: url
#   Searchkick.client = Elasticsearch::Client.new(hosts: url, retry_on_failure: true, transport_options: {request: {timeout: 250}})
# end

# Searchkick.client = Elasticsearch::Client.new(hosts: ["localhost:9200"], retry_on_failure: true, transport_options: {request: {timeout: 250}})
