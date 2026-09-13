# frozen_string_literal: true

# ================================================================
# SEARCHKICK / ELASTICSEARCH
#
# Entity Command Center uses Elasticsearch exclusively.
# OpenSearch is intentionally not configured.
# ================================================================

Searchkick.client_type = :elasticsearch

Searchkick.client_options = {
  retry_on_failure: 2,
  transport_options: {
    request: {
      timeout: 10
    }
  }
}

# Elasticsearch endpoint.
#
# Development:
#   ELASTICSEARCH_URL=http://localhost:9200
#
# Production:
#   ELASTICSEARCH_URL=https://user:password@your-host:9243
#
ENV["ELASTICSEARCH_URL"] ||= "http://localhost:9200"
