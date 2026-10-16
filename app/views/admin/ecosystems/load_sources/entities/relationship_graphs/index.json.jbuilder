json.entity do
  json.id @entity.id
  json.name @entity.name
  json.slug @entity.slug
end

json.relationships @relationships do |relationship|
  json.id relationship.id

  json.source_entity_id relationship.source_entity_id
  json.target_entity_id relationship.target_entity_id

  json.relationship_kind relationship.relationship_kind
  json.confidence relationship.confidence
  json.state relationship.state

  json.evidence relationship.evidence

  json.last_discovered_at relationship.last_discovered_at
end