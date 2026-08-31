class Ecosystems::LoadSources::EntityTemplates::EntityTemplateConfiguration < ApplicationRecord
  self.table_name = "ecosystems_load_sources_entity_template_configurations"
  belongs_to :entity_template
  belongs_to :entity_type

  belongs_to :context,
             polymorphic: true

  validates :context_type,
            presence: true

  validates :context_id,
            presence: true

  validates :entity_type_id,
            uniqueness: {
              scope: [:context_type, :context_id]
            }

  scope :active, -> {
    where(active: true)
  }

  # scope :ordered, -> {
  #   order(priority: :desc, created_at: :asc)
  # }

  scope :ordered, -> {
    order(created_at: :asc)
  }


  def setting(key, default = nil)
    settings.fetch(key.to_s, default)
  end
end