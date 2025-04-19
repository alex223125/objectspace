class Frameworks::FrameworkMember < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders, :history]

  belongs_to :framework_folder, class_name: "Frameworks::FrameworkFolder"
  belongs_to :framework_memberable, polymorphic: true

  def closest_framework
    self.framework_folder.framework || self.framework_folder.related_framework
  end

  private

  def slug_candidates
    [ :title,
      [:title, :uuid]
    ]
  end

end
