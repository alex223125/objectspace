json.collection do
  json.id @intelligence[:collection][:id]
  json.name @intelligence[:collection][:name]
  json.status @intelligence[:collection][:status]
end

json.objectives @intelligence[:objectives]
json.questions @intelligence[:questions]
json.findings @intelligence[:findings]
json.milestones @intelligence[:milestones]
json.evidence @intelligence[:evidence]
json.health @intelligence[:health]
json.evidence_coverage @intelligence[:evidence_coverage]
json.unresolved_questions @intelligence[:unresolved_questions]
json.contradictions @intelligence[:contradictions]