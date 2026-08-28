entity_type_class =
  Ecosystems::LoadSources::EntityTypes::EntityType

pressure_source =
  entity_type_class.find_or_create_by!(slug: "pressure-source") do |type|
    type.name = "Pressure Source"
    type.description = "A source capable of creating or contributing to pressure within an ecosystem."
    type.active = true
  end

actor =
  entity_type_class.find_or_create_by!(slug: "actor") do |type|
    type.name = "Actor"
    type.description = "An organisation, institution, group, or other actor capable of influencing an ecosystem."
    type.parent = pressure_source
    type.active = true
  end

entity_type_class.find_or_create_by!(slug: "organisation") do |type|
  type.name = "Organisation"
  type.description = "An organisation that participates in or influences an ecosystem."
  type.parent = actor
  type.active = true
end

entity_type_class.find_or_create_by!(slug: "institution") do |type|
  type.name = "Institution"
  type.description = "An institution with a defined role, authority, governance structure, or societal function."
  type.parent = actor
  type.active = true
end

entity_type_class.find_or_create_by!(slug: "infrastructure") do |type|
  type.name = "Infrastructure"
  type.description = "Physical, digital, technical, or organisational infrastructure."
  type.parent = pressure_source
  type.active = true
end

threat =
  entity_type_class.find_or_create_by!(slug: "threat") do |type|
    type.name = "Threat"
    type.description = "A threat capable of causing harm or creating pressure within an ecosystem."
    type.parent = pressure_source
    type.active = true
  end

entity_type_class.find_or_create_by!(slug: "attack") do |type|
  type.name = "Attack"
  type.description = "An attack or hostile activity associated with a threat."
  type.parent = threat
  type.active = true
end

entity_type_class.find_or_create_by!(slug: "vulnerability") do |type|
  type.name = "Vulnerability"
  type.description = "A weakness that can be exploited or contribute to risk."
  type.parent = threat
  type.active = true
end
