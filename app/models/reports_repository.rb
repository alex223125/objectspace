class ReportsRepository < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  acts_as_taggable_on :tags

  belongs_to :ownerable, polymorphic: true

  has_many :reports_repository_folders, class_name: "Folder", dependent: :destroy
  has_many :algorithm_reports, class_name: "AlgorithmReports::AlgorithmReport"

  private

  def slug_candidates
    [ :title,
      [:title, :uuid]
    ]
  end

end