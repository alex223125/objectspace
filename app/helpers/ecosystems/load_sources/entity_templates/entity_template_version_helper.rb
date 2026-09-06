module Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersionHelper

  def field_count
    fields.size
  end


  def section_count
    sections.size
  end


  def display_name
    template_name =
      entity_template&.name.presence ||
        "Entity Template"

    "#{template_name} v#{version}"
  end

end