class Algorithms::Algorithm < ApplicationRecord

  ALLOWED_AMOUNT_OF_INTERFACE_MEMBERS_FOR_CLASS_LEVEL_ALGORITHMS = 1

  extend Pagy::Searchkick
  searchkick callbacks: :async,
             text_middle: [:title, :source_page_description],
             word: [:list_of_tags, :ownerable_id]
  scope :search_import, -> { includes(:tags) }
  acts_as_taggable_on :tags

  belongs_to :folder, class_name: "Folder", optional: true
  belongs_to :ownerable, polymorphic: true

  # open question: should it be has_one or allow has_many for DPO ?
  has_many :simple_classes, as: :instructionable, class_name: "SimpleClasses::SimpleClass"

  # has_many :units, -> { order(position: :asc) }
  # accepts_nested_attributes_for :units, reject_if: :all_blank, allow_destroy: true

  has_many :algorithm_versions, dependent: :destroy, class_name: "Algorithms::AlgorithmVersion"
  accepts_nested_attributes_for :algorithm_versions, allow_destroy: true

  # has_many :steps, as: :algorithmic_steps, through: :algorithm_versions, class_name: "Algorithms::Step"
  # accepts_nested_attributes_for :steps

  # has_many :substeps

  has_many :interface_members, as: :memberable, class_name: "SimpleClasses::InterfaceMember"
  has_many :interfacable_simple_classes,
           :through => :interface_members,
           class_name: "SimpleClasses::SimpleClass",
           source: :simple_class

  validates :title, presence: true, allow_blank: false
  validates_with Algorithms::SizeOfStepsValidator, on: [:create]

  validates :folder, presence: true, if: :regular_algorithm?

  validate :class_level_algorithm_has_only_one_interface_member

  def regular_algorithm?
    binding.pry
    # TODO: change on normal check
    self.functional_type != Algorithms::FunctionalTypes[:class_level]
  end

    include PgSearch::Model
  pg_search_scope :english_global_search,
                  against: {
                    title: 'A',
                    source_page_description: 'B'
                  },
                  using: {
                    tsearch: {
                      dictionary: 'english',
                      tsvector_column: 'searchable',
                      any_word: true,
                      prefix: true
                    }
                  }


  def default_version
    Algorithms::AlgorithmVersion.find_by(id: self.default_version_id)
  end

  def class_key
    "algorithm"
  end

  def uniq_key
    class_key + self.uuid
  end


  def search_data
    {
      title: title,
      source_page_description: source_page_description,
      list_of_tags: tag_list,
      ownerable_id: ownerable_id,
      folder_id: folder_id
    }
  end

  private

  def class_level_algorithm_has_only_one_interface_member
    binding.pry
    unless self.interface_members.length == ALLOWED_AMOUNT_OF_INTERFACE_MEMBERS_FOR_CLASS_LEVEL_ALGORITHMS
      errors.add(:interface_members, "must have one interface member")
    end
  end

end
