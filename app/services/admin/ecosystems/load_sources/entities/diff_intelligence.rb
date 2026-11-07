# frozen_string_literal: true

require_relative "diff_intelligence/configuration"
require_relative "diff_intelligence/identity_resolution"
require_relative "diff_intelligence/identity_resolver"
require_relative "diff_intelligence/resolve_array"
require_relative "diff_intelligence/resolve_array_identities"
require_relative "diff_intelligence/semantic_fact"
require_relative "diff_intelligence/array_semantic_facts"
require_relative "diff_intelligence/inline_string_diff"
require_relative "diff_intelligence/semantic_array_diff"
require_relative "diff_intelligence/semantic_diff_result"
require_relative "diff_intelligence/build_comparison_insight"
require_relative "diff_intelligence/semantic_comparator"

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
      end
    end
  end
end