module Forms
  module Improvements
    class TechnologyRelatedImprovementsSearchFrom
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations

      TECH_TYPES_MAPPING = {
        methods: "Units::UnitVersion"
      }.freeze

      SORT_BY_OPTIONS = ["newest", "oldest", "most_commented", "least_commented",
                        "recently_updated", "least_recently_updated"].freeze
      STATUS_OPTIONS = ["all", "open", "closed"].freeze

      CREATED_AT_SORT_OPTIONS = ["newest", "oldest"].freeze
      COMMENTS_SORT_OPTIONS = ["most_commented", "least_commented"].freeze
      UPDATED_AT_SORT_OPTIONS = ["recently_updated", "least_recently_updated"].freeze

      attribute :tech_id, type: String
      attribute :tech_type, type: String
      attribute :query, type: String
      attribute :status, type: String
      attribute :sort_by, type: String
      attribute :tech_version, type: String
      attribute :page, type: String
      attribute :items_per_page, type: Integer, default: 3

      validates :tech_id, :tech_type, :status, :sort_by, :tech_version, presence: true
      validates_inclusion_of :status, in: STATUS_OPTIONS
      validates_inclusion_of :sort_by, in: SORT_BY_OPTIONS

      attr_reader :improvements

      # newest
      # oldest
      # most_commented
      # least_commented
      # recently_updated
      # least_recently_updated

      # module Improvements
      #   class ActiveStatusTypes < ActiveEnum::Base
      #     value :id => 1, :name => :open
      #     value :id => 2, :name => :closed
      #   end
      # end

      # => #<ActionController::Parameters {"tech_id"=>"fasafsasf", "tech_type"=>"methods", "page"=>"1",
      #   # "query"=>"1111", "status"=>"view_all", "sort_by"=>"newest", "tech_version"=>"all"} permitted: true>


      # attribute :fair, type: Boolean
      # attribute :ecologic, type: Boolean
      # attribute :small_and_precious, type: Boolean
      # attribute :swappable, type: Boolean
      # attribute :borrowable, type: Boolean
      #

      # attribute :category_id, type: Integer
      # attribute :exclude_category_ids, type: Array
      # attribute :zip, type: String
      # attribute :order_by, type: String,
      #   default_blank: true
      # attribute :search_in_content, type: Boolean
      # attribute :price_from, type: String
      # attribute :price_to, type: String
      # attribute :transport_bike_courier, type: Boolean

      # def initialize(params= {})
      # end

      def submit
        binding.pry
        set_basic_scope
        binding.pry
        search if @improvements.present?
        binding.pry
        sort if @improvements.present?
      end

      private

      def set_basic_scope
        binding.pry
        if tech_version == "all"

          binding.pry
          @improvements = find_current_technology_version.whole_unit.improvements.uniq
        else

          binding.pry
          @improvements = find_technology_version.improvements
        end
      end

      def search
        binding.pry
        searchkick_result = ::Improvements::Improvement.search(query, where: {id: @improvements.pluck(:id)},
                            operator: "or", fields: [:title, :content], match: :text_middle)
        @improvements = ::Improvements::Improvement.where(id: searchkick_result.pluck(:id)) if searchkick_result.any?
      end

      def technology_type
        binding.pry
        TECH_TYPES_MAPPING[self.tech_type.to_sym].constantize
      end

      def find_current_technology_version
        binding.pry
        technology_type.find(self.tech_id)
      end

      def find_technology_version
        binding.pry
        technology_type.find(self.tech_version)
      end

      def filter_by_status
        binding.pry
        if status == "all"
          # do nothing
        else
          binding.pry
          @improvements = @improvements.where(active_status: Improvements::ActiveStatusTypes[status])
        end
      end

      def sort_by_created_at
        binding.pry
        if sort_by == "newest"

          binding.pry
          @improvements = @improvements.by_earliest_created
        elsif sort_by == "oldest"

          binding.pry
          @improvements = @improvements.by_recently_created
        end
      end

      def sort_by_comments
        binding.pry
        # @results = @results.includes(:comments)
      end

      def sort_by_updated_at
        binding.pry
        if sort_by == "recently_updated"

          binding.pry
          @improvements = @improvements.by_earliest_updated
        elsif sort_by == "least_recently_updated"

          binding.pry
          @improvements = @improvements.by_recently_updated
        end
      end

      def sort
        binding.pry
        if CREATED_AT_SORT_OPTIONS.include?(sort_by)
          binding.pry
          sort_by_created_at
        elsif COMMENTS_SORT_OPTIONS.include?(sort_by)
          binding.pry
          sort_by_comments
        elsif UPDATED_AT_SORT_OPTIONS.include?(sort_by)
          binding.pry
          sort_by_updated_at
        end
      end
    end
  end
end
