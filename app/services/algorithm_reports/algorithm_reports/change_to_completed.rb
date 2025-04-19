module Services
  module AlgorithmReports
    module AlgorithmReports
      class ChangeToCompleted

        attr_reader :errors, :algorithm_report

        def initialize(algorithm_report)
          @algorithm_report = algorithm_report
        end

        def call
          ActiveRecord::Base.transaction do
            binding.pry
            @algorithm_report.completion_state = ::AlgorithmReports::CompletionStateTypes[:completed]
            @algorithm_report.save!
          end
        rescue ActiveRecord::RecordInvalid => e

          binding.pry
          @errors = e.message
          Rails.logger.error(@errors)
        end

        private




      end
    end
  end
end