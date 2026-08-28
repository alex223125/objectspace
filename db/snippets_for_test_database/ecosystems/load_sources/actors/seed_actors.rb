# ============================================================
# Ecosystems → Load Sources → Actors
# ============================================================

actor_class = Ecosystems::LoadSources::Actors::Actor

actors = [
  {
    name: "Government Institution",
    slug: "government-institution",
    description: "A public institution that can influence, regulate, operate, or participate in an ecosystem.",
    status: "published"
  },
  {
    name: "Regulatory Authority",
    slug: "regulatory-authority",
    description: "An institution responsible for establishing, monitoring, or enforcing rules and standards.",
    status: "published"
  },
  {
    name: "Technology Company",
    slug: "technology-company",
    description: "A company that develops, operates, or provides technology, infrastructure, platforms, or services.",
    status: "published"
  },
  {
    name: "Internet Service Provider",
    slug: "internet-service-provider",
    description: "An organisation that provides connectivity and operates network infrastructure and related services.",
    status: "published"
  },
  {
    name: "Research Institution",
    slug: "research-institution",
    description: "An institution that produces research, knowledge, methods, technologies, or evidence.",
    status: "published"
  },
  {
    name: "Standards Organisation",
    slug: "standards-organisation",
    description: "An organisation that develops, maintains, or promotes technical or operational standards.",
    status: "published"
  },
  {
    name: "Non-Governmental Organisation",
    slug: "non-governmental-organisation",
    description: "An independent organisation participating in advocacy, research, services, policy, or community activities.",
    status: "published"
  },
  {
    name: "Open Source Community",
    slug: "open-source-community",
    description: "A community that collaboratively develops, maintains, discusses, and improves open source projects.",
    status: "published"
  },
  {
    name: "Developer Community",
    slug: "developer-community",
    description: "A community of developers sharing knowledge, practices, tools, methods, and technical solutions.",
    status: "published"
  },
  {
    name: "Individual Researcher",
    slug: "individual-researcher",
    description: "An individual who produces, investigates, evaluates, or communicates knowledge and evidence.",
    status: "draft"
  },
  {
    name: "Security Researcher",
    slug: "security-researcher",
    description: "An individual or group researching vulnerabilities, attacks, defensive techniques, and security practices.",
    status: "published"
  },
  {
    name: "Industry Consortium",
    slug: "industry-consortium",
    description: "A group of organisations collaborating around shared technical, commercial, or industry interests.",
    status: "published"
  }
]

actors.each do |attributes|
  actor = actor_class.find_or_initialize_by(slug: attributes[:slug])
  actor.assign_attributes(attributes)
  actor.save!
end

puts "Created/updated #{actors.length} actors."
