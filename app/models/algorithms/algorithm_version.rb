class Algorithms::AlgorithmVersion < ApplicationRecord
  include Unitable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  belongs_to :algorithm

  # has_many :control_structures, class_name: "Algorithms::ControlStructure"
  # accepts_nested_attributes_for :control_structures

  has_many :nodes, class_name: "Algorithms::Nodes::Node"
  accepts_nested_attributes_for :nodes, allow_destroy: true

  # we need it to create initial control structure "following"
  has_many :control_structures, class_name: "Algorithms::Nodes::ControlStructure"
  accepts_nested_attributes_for :control_structures, allow_destroy: true

  # has_many :attachments, as: :attachable, class_name: "Attachment"
  # accepts_nested_attributes_for :control_structures, allow_destroy: true

  # has_many :steps, class_name: "Algorithms::Step"
  # accepts_nested_attributes_for :steps

  # has_many :substeps, as: :substepable

  validates :control_structures, presence: { message: "Algorithm should have at least 1 step" }
  # validates :nodes, presence: { message: "Algorithm should have at least 1 step" }

  validates :title, presence: true

  alias_method :whole_unit, :algorithm

  def class_key
    "algorithm_version"
  end

  def uniq_key
    class_key + self.uuid
  end

  private

  def slug_candidates
    [ :title,
      [:title, :id]
    ]
  end

end