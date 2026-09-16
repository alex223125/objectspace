# frozen_string_literal: true

# ============================================================
# Definition Library
# ============================================================
#
# Creates production-ready entity structures.
#
# Architecture:
#
# DefinitionTemplate
#   └── DefinitionTemplateVersion
#         └── definition = { "fields" => [...] }
#
# ============================================================

DefinitionTemplate =
  Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionTemplate

DefinitionTemplateVersion =
  Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionTemplateVersion

definitions = [

  # ==========================================================
  # PEOPLE
  # ==========================================================

  {
    external_id: "person",
    name: "Person",
    slug: "person",
    category: "People",
    description: "A general-purpose person or individual record.",
    icon: "👤",
    color: "#8B5CF6",
    featured: true,
    is_new: false,
    active: true,
    tags: %w[
      people
      person
      contact
      individual
      identity
    ],
    fields: [
      {
        "key" => "first_name",
        "name" => "First Name",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "last_name",
        "name" => "Last Name",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "email",
        "name" => "Email",
        "type" => "email",
        "required" => false,
        "active" => true
      },
      {
        "key" => "phone",
        "name" => "Phone",
        "type" => "string",
        "required" => false,
        "active" => true
      },
      {
        "key" => "date_of_birth",
        "name" => "Date of Birth",
        "type" => "date",
        "required" => false,
        "active" => true
      },
      {
        "key" => "notes",
        "name" => "Notes",
        "type" => "text",
        "required" => false,
        "active" => true
      }
    ]
  },

  # ==========================================================
  # CONTACT
  # ==========================================================

  {
    external_id: "contact",
    name: "Contact",
    slug: "contact",
    category: "People",
    description: "A flexible contact record for people, customers, and leads.",
    icon: "📇",
    color: "#06B6D4",
    featured: true,
    is_new: false,
    active: true,
    tags: %w[
      contact
      crm
      customer
      lead
      people
    ],
    fields: [
      {
        "key" => "name",
        "name" => "Name",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "email",
        "name" => "Email",
        "type" => "email",
        "required" => false,
        "active" => true
      },
      {
        "key" => "phone",
        "name" => "Phone",
        "type" => "string",
        "required" => false,
        "active" => true
      },
      {
        "key" => "company",
        "name" => "Company",
        "type" => "string",
        "required" => false,
        "active" => true
      },
      {
        "key" => "job_title",
        "name" => "Job Title",
        "type" => "string",
        "required" => false,
        "active" => true
      },
      {
        "key" => "notes",
        "name" => "Notes",
        "type" => "text",
        "required" => false,
        "active" => true
      }
    ]
  },

  # ==========================================================
  # COMPANY
  # ==========================================================

  {
    external_id: "company",
    name: "Company",
    slug: "company",
    category: "Organizations",
    description: "A business or organization profile.",
    icon: "🏢",
    color: "#3B82F6",
    featured: true,
    is_new: false,
    active: true,
    tags: %w[
      company
      business
      organization
      crm
    ],
    fields: [
      {
        "key" => "name",
        "name" => "Company Name",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "website",
        "name" => "Website",
        "type" => "url",
        "required" => false,
        "active" => true
      },
      {
        "key" => "email",
        "name" => "Email",
        "type" => "email",
        "required" => false,
        "active" => true
      },
      {
        "key" => "phone",
        "name" => "Phone",
        "type" => "string",
        "required" => false,
        "active" => true
      },
      {
        "key" => "industry",
        "name" => "Industry",
        "type" => "string",
        "required" => false,
        "active" => true
      },
      {
        "key" => "description",
        "name" => "Description",
        "type" => "text",
        "required" => false,
        "active" => true
      }
    ]
  },

  # ==========================================================
  # PRODUCT
  # ==========================================================

  {
    external_id: "product",
    name: "Product",
    slug: "product",
    category: "Commerce",
    description: "A product or sellable item.",
    icon: "📦",
    color: "#F59E0B",
    featured: true,
    is_new: false,
    active: true,
    tags: %w[
      product
      commerce
      inventory
      catalog
    ],
    fields: [
      {
        "key" => "name",
        "name" => "Product Name",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "sku",
        "name" => "SKU",
        "type" => "string",
        "required" => false,
        "active" => true
      },
      {
        "key" => "description",
        "name" => "Description",
        "type" => "text",
        "required" => false,
        "active" => true
      },
      {
        "key" => "price",
        "name" => "Price",
        "type" => "number",
        "required" => false,
        "active" => true
      },
      {
        "key" => "currency",
        "name" => "Currency",
        "type" => "string",
        "required" => false,
        "active" => true
      },
      {
        "key" => "active",
        "name" => "Active",
        "type" => "boolean",
        "required" => true,
        "active" => true
      }
    ]
  },

  # ==========================================================
  # ORDER
  # ==========================================================

  {
    external_id: "order",
    name: "Order",
    slug: "order",
    category: "Commerce",
    description: "A customer order or purchase transaction.",
    icon: "🧾",
    color: "#10B981",
    featured: true,
    is_new: false,
    active: true,
    tags: %w[
      order
      commerce
      sales
      purchase
    ],
    fields: [
      {
        "key" => "order_number",
        "name" => "Order Number",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "customer_name",
        "name" => "Customer Name",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "customer_email",
        "name" => "Customer Email",
        "type" => "email",
        "required" => false,
        "active" => true
      },
      {
        "key" => "order_date",
        "name" => "Order Date",
        "type" => "datetime",
        "required" => true,
        "active" => true
      },
      {
        "key" => "total",
        "name" => "Total",
        "type" => "number",
        "required" => true,
        "active" => true
      },
      {
        "key" => "status",
        "name" => "Status",
        "type" => "select",
        "required" => true,
        "active" => true,
        "options" => [
          "pending",
          "paid",
          "processing",
          "shipped",
          "completed",
          "cancelled"
        ]
      }
    ]
  },

  # ==========================================================
  # PROJECT
  # ==========================================================

  {
    external_id: "project",
    name: "Project",
    slug: "project",
    category: "Work",
    description: "A project with ownership, status, dates, and description.",
    icon: "📁",
    color: "#6366F1",
    featured: true,
    is_new: false,
    active: true,
    tags: %w[
      project
      work
      management
      planning
    ],
    fields: [
      {
        "key" => "name",
        "name" => "Project Name",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "description",
        "name" => "Description",
        "type" => "text",
        "required" => false,
        "active" => true
      },
      {
        "key" => "status",
        "name" => "Status",
        "type" => "select",
        "required" => true,
        "active" => true,
        "options" => [
          "planned",
          "active",
          "on_hold",
          "completed",
          "cancelled"
        ]
      },
      {
        "key" => "start_date",
        "name" => "Start Date",
        "type" => "date",
        "required" => false,
        "active" => true
      },
      {
        "key" => "due_date",
        "name" => "Due Date",
        "type" => "date",
        "required" => false,
        "active" => true
      }
    ]
  },

  # ==========================================================
  # TASK
  # ==========================================================

  {
    external_id: "task",
    name: "Task",
    slug: "task",
    category: "Work",
    description: "A task with priority, status, assignment, and due date.",
    icon: "✓",
    color: "#14B8A6",
    featured: true,
    is_new: true,
    active: true,
    tags: %w[
      task
      todo
      work
      productivity
    ],
    fields: [
      {
        "key" => "title",
        "name" => "Title",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "description",
        "name" => "Description",
        "type" => "text",
        "required" => false,
        "active" => true
      },
      {
        "key" => "status",
        "name" => "Status",
        "type" => "select",
        "required" => true,
        "active" => true,
        "options" => [
          "todo",
          "in_progress",
          "blocked",
          "done"
        ]
      },
      {
        "key" => "priority",
        "name" => "Priority",
        "type" => "select",
        "required" => false,
        "active" => true,
        "options" => [
          "low",
          "medium",
          "high",
          "urgent"
        ]
      },
      {
        "key" => "due_date",
        "name" => "Due Date",
        "type" => "date",
        "required" => false,
        "active" => true
      }
    ]
  },

  # ==========================================================
  # EVENT
  # ==========================================================

  {
    external_id: "event",
    name: "Event",
    slug: "event",
    category: "Planning",
    description: "An event with timing, location, and description.",
    icon: "📅",
    color: "#EC4899",
    featured: false,
    is_new: true,
    active: true,
    tags: %w[
      event
      calendar
      schedule
      planning
    ],
    fields: [
      {
        "key" => "title",
        "name" => "Title",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "description",
        "name" => "Description",
        "type" => "text",
        "required" => false,
        "active" => true
      },
      {
        "key" => "start_at",
        "name" => "Start",
        "type" => "datetime",
        "required" => true,
        "active" => true
      },
      {
        "key" => "end_at",
        "name" => "End",
        "type" => "datetime",
        "required" => false,
        "active" => true
      },
      {
        "key" => "location",
        "name" => "Location",
        "type" => "string",
        "required" => false,
        "active" => true
      }
    ]
  },

  # ==========================================================
  # ARTICLE
  # ==========================================================

  {
    external_id: "article",
    name: "Article",
    slug: "article",
    category: "Content",
    description: "A long-form article, post, or editorial document.",
    icon: "📝",
    color: "#F97316",
    featured: false,
    is_new: false,
    active: true,
    tags: %w[
      article
      content
      blog
      publishing
    ],
    fields: [
      {
        "key" => "title",
        "name" => "Title",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "slug",
        "name" => "Slug",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "excerpt",
        "name" => "Excerpt",
        "type" => "text",
        "required" => false,
        "active" => true
      },
      {
        "key" => "content",
        "name" => "Content",
        "type" => "text",
        "required" => true,
        "active" => true
      },
      {
        "key" => "published",
        "name" => "Published",
        "type" => "boolean",
        "required" => true,
        "active" => true
      }
    ]
  },

  # ==========================================================
  # LOCATION
  # ==========================================================

  {
    external_id: "location",
    name: "Location",
    slug: "location",
    category: "Places",
    description: "A physical or geographic location.",
    icon: "📍",
    color: "#EF4444",
    featured: false,
    is_new: false,
    active: true,
    tags: %w[
      location
      address
      place
      geography
    ],
    fields: [
      {
        "key" => "name",
        "name" => "Name",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "address",
        "name" => "Address",
        "type" => "string",
        "required" => false,
        "active" => true
      },
      {
        "key" => "city",
        "name" => "City",
        "type" => "string",
        "required" => false,
        "active" => true
      },
      {
        "key" => "country",
        "name" => "Country",
        "type" => "string",
        "required" => false,
        "active" => true
      },
      {
        "key" => "latitude",
        "name" => "Latitude",
        "type" => "number",
        "required" => false,
        "active" => true
      },
      {
        "key" => "longitude",
        "name" => "Longitude",
        "type" => "number",
        "required" => false,
        "active" => true
      }
    ]
  },

  # ==========================================================
  # DOCUMENT
  # ==========================================================

  {
    external_id: "document",
    name: "Document",
    slug: "document",
    category: "Content",
    description: "A generic document with metadata and content.",
    icon: "📄",
    color: "#64748B",
    featured: false,
    is_new: false,
    active: true,
    tags: %w[
      document
      file
      content
    ],
    fields: [
      {
        "key" => "title",
        "name" => "Title",
        "type" => "string",
        "required" => true,
        "active" => true
      },
      {
        "key" => "description",
        "name" => "Description",
        "type" => "text",
        "required" => false,
        "active" => true
      },
      {
        "key" => "document_type",
        "name" => "Document Type",
        "type" => "string",
        "required" => false,
        "active" => true
      },
      {
        "key" => "content",
        "name" => "Content",
        "type" => "text",
        "required" => false,
        "active" => true
      }
    ]
  }

]

puts
puts "============================================================"
puts " Loading Definition Library"
puts "============================================================"

created = 0
updated = 0
versions_created = 0

ActiveRecord::Base.transaction do
  definitions.each_with_index do |definition, index|

    puts "[#{index + 1}/#{definitions.length}] #{definition[:category]} / #{definition[:name]}"

    record = DefinitionTemplate.find_or_initialize_by(
      external_id: definition[:external_id]
    )

    was_new = record.new_record?

    record.name = definition[:name]
    record.slug = definition[:slug]
    record.category = definition[:category]
    record.description = definition[:description]
    record.icon = definition[:icon]
    record.color = definition[:color]
    record.featured = definition[:featured]
    record.is_new = definition[:is_new]
    record.active = definition[:active]
    record.tags = definition[:tags]
    record.status = "published"

    record.popularity_score =
      definition[:featured] ? 90 : 60

    record.usage_count ||= 0

    record.metadata ||= {}

    record.save!

    if was_new
      created += 1
    else
      updated += 1
    end

    version = record.versions.find_or_initialize_by(
      version: 1
    )

    version.status = "published"
    version.change_summary = "Initial definition library structure"
    version.definition = {
      "fields" => definition[:fields]
    }
    version.metadata = {
      "source" => "built_in_library"
    }
    version.published_at = Time.current

    if version.new_record?
      versions_created += 1
    end

    version.save!
  end
end

puts
puts "============================================================"
puts " Definition Library Loaded"
puts "============================================================"
puts "Definitions       : #{DefinitionTemplate.count}"
puts "Created           : #{created}"
puts "Updated           : #{updated}"
puts "Versions created  : #{versions_created}"
puts "Published         : #{DefinitionTemplate.where(status: 'published').count}"
puts "With versions     : #{DefinitionTemplate.joins(:versions).distinct.count}"
puts "============================================================"
puts