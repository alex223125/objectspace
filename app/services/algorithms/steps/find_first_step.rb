# DOC: this logic will expand after we will add more control
# structure and special steps like "preferable step to start"
# or parametrized step to continue
module Services
  module Algorithms
    module Steps
      class FindFirstStep

        attr_reader :step

        def initialize(algorithm_version)
          @algorithm_version = algorithm_version
        end

        def call
          @step = @algorithm_version.first_step
        end
      end
    end
  end
end