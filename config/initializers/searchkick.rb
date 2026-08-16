# 1. Instruct the gem to use secure routing
ENV["ELASTICSEARCH_URL"] = "http://localhost:9200"

# 2. Tell Faraday to ignore local development self-signed certificate constraints
Searchkick.client_options = {
  transport_options: {
    ssl: { verify: false } # Disables strict SSL verification for local development only
  }
}