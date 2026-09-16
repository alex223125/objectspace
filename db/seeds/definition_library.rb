# frozen_string_literal: true

# db/seeds/definition_library.rb

#

# Populates the Definition Library with ready-to-use entity definitions.

#

# Safe to run repeatedly:

# bin/rails runner db/seeds/definition_library.rb

#

# Or from db/seeds.rb:

# load Rails.root.join("db/seeds/definition_library.rb")

DefinitionLibraryDefinition =
  Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionLibraryDefinition

definitions = [
  {
    slug: "person",
    name: "Person",
    description: "A general-purpose person profile with identity, contact, and basic profile information.",
    category: "People",
    icon: "👤",
    tags: ["person", "contact", "profile", "identity", "people"],
    version: "1.0",
    active: true,
    featured: true,
    popularity: 98,
    definition_json: {
      "entity_type" => "person",
      "name" => "Person",
      "version" => "1.0",
      "fields" => [
        {
          "key" => "first_name",
          "name" => "First Name",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 1
        },
        {
          "key" => "last_name",
          "name" => "Last Name",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 2
        },
        {
          "key" => "email",
          "name" => "Email",
          "type" => "email",
          "required" => false,
          "active" => true,
          "position" => 3
        },
        {
          "key" => "phone",
          "name" => "Phone",
          "type" => "string",
          "required" => false,
          "active" => true,
          "position" => 4
        },
        {
          "key" => "date_of_birth",
          "name" => "Date of Birth",
          "type" => "date",
          "required" => false,
          "active" => true,
          "position" => 5
        },
        {
          "key" => "bio",
          "name" => "Bio",
          "type" => "text",
          "required" => false,
          "active" => true,
          "position" => 6
        }
      ]
    }
  },

  {
    slug: "customer",
    name: "Customer",
    description: "Customer profile designed for CRM, sales, support, and account-management workflows.",
    category: "CRM",
    icon: "🤝",
    tags: ["customer", "crm", "sales", "account", "contact"],
    version: "1.0",
    active: true,
    featured: true,
    popularity: 97,
    definition_json: {
      "entity_type" => "customer",
      "name" => "Customer",
      "version" => "1.0",
      "fields" => [
        {
          "key" => "customer_number",
          "name" => "Customer Number",
          "type" => "string",
          "required" => false,
          "active" => true,
          "position" => 1
        },
        {
          "key" => "company_name",
          "name" => "Company Name",
          "type" => "string",
          "required" => false,
          "active" => true,
          "position" => 2
        },
        {
          "key" => "first_name",
          "name" => "First Name",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 3
        },
        {
          "key" => "last_name",
          "name" => "Last Name",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 4
        },
        {
          "key" => "email",
          "name" => "Email",
          "type" => "email",
          "required" => true,
          "active" => true,
          "position" => 5
        },
        {
          "key" => "phone",
          "name" => "Phone",
          "type" => "string",
          "required" => false,
          "active" => true,
          "position" => 6
        },
        {
          "key" => "status",
          "name" => "Status",
          "type" => "select",
          "required" => true,
          "active" => true,
          "position" => 7,
          "options" => [
            { "value" => "lead", "label" => "Lead" },
            { "value" => "active", "label" => "Active" },
            { "value" => "inactive", "label" => "Inactive" }
          ]
        }
      ]
    }
  },

  {
    slug: "company",
    name: "Company",
    description: "Business organization profile for directories, CRM, marketplaces, and enterprise applications.",
    category: "Business",
    icon: "🏢",
    tags: ["company", "business", "organization", "enterprise"],
    version: "1.0",
    active: true,
    featured: true,
    popularity: 96,
    definition_json: {
      "entity_type" => "company",
      "name" => "Company",
      "version" => "1.0",
      "fields" => [
        {
          "key" => "name",
          "name" => "Company Name",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 1
        },
        {
          "key" => "legal_name",
          "name" => "Legal Name",
          "type" => "string",
          "required" => false,
          "active" => true,
          "position" => 2
        },
        {
          "key" => "registration_number",
          "name" => "Registration Number",
          "type" => "string",
          "required" => false,
          "active" => true,
          "position" => 3
        },
        {
          "key" => "email",
          "name" => "Email",
          "type" => "email",
          "required" => false,
          "active" => true,
          "position" => 4
        },
        {
          "key" => "phone",
          "name" => "Phone",
          "type" => "string",
          "required" => false,
          "active" => true,
          "position" => 5
        },
        {
          "key" => "website",
          "name" => "Website",
          "type" => "url",
          "required" => false,
          "active" => true,
          "position" => 6
        },
        {
          "key" => "description",
          "name" => "Description",
          "type" => "text",
          "required" => false,
          "active" => true,
          "position" => 7
        }
      ]
    }
  },

  {
    slug: "product",
    name: "Product",
    description: "Flexible product catalog definition for commerce, inventory, marketplaces, and product management.",
    category: "Commerce",
    icon: "📦",
    tags: ["product", "commerce", "catalog", "inventory", "shop"],
    version: "1.0",
    active: true,
    featured: true,
    popularity: 99,
    definition_json: {
      "entity_type" => "product",
      "name" => "Product",
      "version" => "1.0",
      "fields" => [
        {
          "key" => "sku",
          "name" => "SKU",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 1
        },
        {
          "key" => "name",
          "name" => "Product Name",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 2
        },
        {
          "key" => "description",
          "name" => "Description",
          "type" => "text",
          "required" => false,
          "active" => true,
          "position" => 3
        },
        {
          "key" => "price",
          "name" => "Price",
          "type" => "number",
          "required" => true,
          "active" => true,
          "position" => 4
        },
        {
          "key" => "currency",
          "name" => "Currency",
          "type" => "select",
          "required" => true,
          "active" => true,
          "position" => 5,
          "options" => [
            { "value" => "EUR", "label" => "EUR" },
            { "value" => "USD", "label" => "USD" },
            { "value" => "GBP", "label" => "GBP" }
          ]
        },
        {
          "key" => "stock_quantity",
          "name" => "Stock Quantity",
          "type" => "integer",
          "required" => false,
          "active" => true,
          "position" => 6
        },
        {
          "key" => "active",
          "name" => "Active",
          "type" => "boolean",
          "required" => true,
          "active" => true,
          "position" => 7
        }
      ]
    }
  },

  {
    slug: "order",
    name: "Order",
    description: "Commerce order structure for checkout, fulfillment, payment, and order management.",
    category: "Commerce",
    icon: "🛒",
    tags: ["order", "commerce", "checkout", "payment", "fulfillment"],
    version: "1.0",
    active: true,
    featured: true,
    popularity: 94,
    definition_json: {
      "entity_type" => "order",
      "name" => "Order",
      "version" => "1.0",
      "fields" => [
        {
          "key" => "order_number",
          "name" => "Order Number",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 1
        },
        {
          "key" => "customer_id",
          "name" => "Customer",
          "type" => "reference",
          "required" => true,
          "active" => true,
          "position" => 2
        },
        {
          "key" => "order_date",
          "name" => "Order Date",
          "type" => "datetime",
          "required" => true,
          "active" => true,
          "position" => 3
        },
        {
          "key" => "status",
          "name" => "Status",
          "type" => "select",
          "required" => true,
          "active" => true,
          "position" => 4,
          "options" => [
            { "value" => "pending", "label" => "Pending" },
            { "value" => "paid", "label" => "Paid" },
            { "value" => "processing", "label" => "Processing" },
            { "value" => "shipped", "label" => "Shipped" },
            { "value" => "completed", "label" => "Completed" },
            { "value" => "cancelled", "label" => "Cancelled" }
          ]
        },
        {
          "key" => "total",
          "name" => "Total",
          "type" => "number",
          "required" => true,
          "active" => true,
          "position" => 5
        },
        {
          "key" => "notes",
          "name" => "Notes",
          "type" => "text",
          "required" => false,
          "active" => true,
          "position" => 6
        }
      ]
    }
  },

  {
    slug: "address",
    name: "Address",
    description: "Reusable postal address structure for customers, companies, contacts, shipping, and billing.",
    category: "Contact",
    icon: "📍",
    tags: ["address", "location", "shipping", "billing", "contact"],
    version: "1.0",
    active: true,
    featured: false,
    popularity: 91,
    definition_json: {
      "entity_type" => "address",
      "name" => "Address",
      "version" => "1.0",
      "fields" => [
        {
          "key" => "address_line_1",
          "name" => "Address Line 1",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 1
        },
        {
          "key" => "address_line_2",
          "name" => "Address Line 2",
          "type" => "string",
          "required" => false,
          "active" => true,
          "position" => 2
        },
        {
          "key" => "city",
          "name" => "City",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 3
        },
        {
          "key" => "state",
          "name" => "State / Province",
          "type" => "string",
          "required" => false,
          "active" => true,
          "position" => 4
        },
        {
          "key" => "postal_code",
          "name" => "Postal Code",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 5
        },
        {
          "key" => "country",
          "name" => "Country",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 6
        }
      ]
    }
  },

  {
    slug: "employee",
    name: "Employee",
    description: "Employee profile for HR, internal directories, workforce management, and organizational systems.",
    category: "People",
    icon: "💼",
    tags: ["employee", "hr", "staff", "workforce", "people"],
    version: "1.0",
    active: true,
    featured: true,
    popularity: 92,
    definition_json: {
      "entity_type" => "employee",
      "name" => "Employee",
      "version" => "1.0",
      "fields" => [
        {
          "key" => "employee_number",
          "name" => "Employee Number",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 1
        },
        {
          "key" => "first_name",
          "name" => "First Name",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 2
        },
        {
          "key" => "last_name",
          "name" => "Last Name",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 3
        },
        {
          "key" => "email",
          "name" => "Work Email",
          "type" => "email",
          "required" => true,
          "active" => true,
          "position" => 4
        },
        {
          "key" => "job_title",
          "name" => "Job Title",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 5
        },
        {
          "key" => "department",
          "name" => "Department",
          "type" => "string",
          "required" => false,
          "active" => true,
          "position" => 6
        },
        {
          "key" => "start_date",
          "name" => "Start Date",
          "type" => "date",
          "required" => false,
          "active" => true,
          "position" => 7
        }
      ]
    }
  },

  {
    slug: "project",
    name: "Project",
    description: "Project management structure for teams, delivery, planning, deadlines, and project tracking.",
    category: "Operations",
    icon: "📋",
    tags: ["project", "management", "tasks", "operations", "planning"],
    version: "1.0",
    active: true,
    featured: false,
    popularity: 89,
    definition_json: {
      "entity_type" => "project",
      "name" => "Project",
      "version" => "1.0",
      "fields" => [
        {
          "key" => "name",
          "name" => "Project Name",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 1
        },
        {
          "key" => "description",
          "name" => "Description",
          "type" => "text",
          "required" => false,
          "active" => true,
          "position" => 2
        },
        {
          "key" => "owner",
          "name" => "Project Owner",
          "type" => "reference",
          "required" => false,
          "active" => true,
          "position" => 3
        },
        {
          "key" => "status",
          "name" => "Status",
          "type" => "select",
          "required" => true,
          "active" => true,
          "position" => 4,
          "options" => [
            { "value" => "planned", "label" => "Planned" },
            { "value" => "active", "label" => "Active" },
            { "value" => "on_hold", "label" => "On Hold" },
            { "value" => "completed", "label" => "Completed" }
          ]
        },
        {
          "key" => "start_date",
          "name" => "Start Date",
          "type" => "date",
          "required" => false,
          "active" => true,
          "position" => 5
        },
        {
          "key" => "due_date",
          "name" => "Due Date",
          "type" => "date",
          "required" => false,
          "active" => true,
          "position" => 6
        }
      ]
    }
  },

  {
    slug: "event",
    name: "Event",
    description: "Event structure for meetings, appointments, conferences, bookings, and scheduled activities.",
    category: "Operations",
    icon: "📅",
    tags: ["event", "calendar", "meeting", "appointment", "booking"],
    version: "1.0",
    active: true,
    featured: false,
    popularity: 88,
    definition_json: {
      "entity_type" => "event",
      "name" => "Event",
      "version" => "1.0",
      "fields" => [
        {
          "key" => "title",
          "name" => "Title",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 1
        },
        {
          "key" => "description",
          "name" => "Description",
          "type" => "text",
          "required" => false,
          "active" => true,
          "position" => 2
        },
        {
          "key" => "start_at",
          "name" => "Start",
          "type" => "datetime",
          "required" => true,
          "active" => true,
          "position" => 3
        },
        {
          "key" => "end_at",
          "name" => "End",
          "type" => "datetime",
          "required" => true,
          "active" => true,
          "position" => 4
        },
        {
          "key" => "location",
          "name" => "Location",
          "type" => "string",
          "required" => false,
          "active" => true,
          "position" => 5
        },
        {
          "key" => "url",
          "name" => "Event URL",
          "type" => "url",
          "required" => false,
          "active" => true,
          "position" => 6
        }
      ]
    }
  },

  {
    slug: "document",
    name: "Document",
    description: "Generic document metadata structure for files, contracts, reports, attachments, and digital records.",
    category: "Content",
    icon: "📄",
    tags: ["document", "file", "content", "attachment", "record"],
    version: "1.0",
    active: true,
    featured: false,
    popularity: 86,
    definition_json: {
      "entity_type" => "document",
      "name" => "Document",
      "version" => "1.0",
      "fields" => [
        {
          "key" => "title",
          "name" => "Title",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 1
        },
        {
          "key" => "document_type",
          "name" => "Document Type",
          "type" => "select",
          "required" => true,
          "active" => true,
          "position" => 2,
          "options" => [
            { "value" => "contract", "label" => "Contract" },
            { "value" => "report", "label" => "Report" },
            { "value" => "invoice", "label" => "Invoice" },
            { "value" => "other", "label" => "Other" }
          ]
        },
        {
          "key" => "description",
          "name" => "Description",
          "type" => "text",
          "required" => false,
          "active" => true,
          "position" => 3
        },
        {
          "key" => "document_url",
          "name" => "Document URL",
          "type" => "url",
          "required" => false,
          "active" => true,
          "position" => 4
        },
        {
          "key" => "created_on",
          "name" => "Created On",
          "type" => "date",
          "required" => false,
          "active" => true,
          "position" => 5
        }
      ]
    }
  },

  {
    slug: "location",
    name: "Location",
    description: "Location structure for offices, venues, stores, facilities, and geographic records.",
    category: "Location",
    icon: "🌎",
    tags: ["location", "place", "venue", "geography", "address"],
    version: "1.0",
    active: true,
    featured: false,
    popularity: 84,
    definition_json: {
      "entity_type" => "location",
      "name" => "Location",
      "version" => "1.0",
      "fields" => [
        {
          "key" => "name",
          "name" => "Location Name",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 1
        },
        {
          "key" => "address",
          "name" => "Address",
          "type" => "string",
          "required" => false,
          "active" => true,
          "position" => 2
        },
        {
          "key" => "city",
          "name" => "City",
          "type" => "string",
          "required" => false,
          "active" => true,
          "position" => 3
        },
        {
          "key" => "country",
          "name" => "Country",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 4
        },
        {
          "key" => "latitude",
          "name" => "Latitude",
          "type" => "number",
          "required" => false,
          "active" => true,
          "position" => 5
        },
        {
          "key" => "longitude",
          "name" => "Longitude",
          "type" => "number",
          "required" => false,
          "active" => true,
          "position" => 6
        }
      ]
    }
  },

  {
    slug: "invoice",
    name: "Invoice",
    description: "Professional invoice structure for billing, accounting, payments, and financial workflows.",
    category: "Finance",
    icon: "🧾",
    tags: ["invoice", "finance", "billing", "accounting", "payment"],
    version: "1.0",
    active: true,
    featured: true,
    popularity: 95,
    definition_json: {
      "entity_type" => "invoice",
      "name" => "Invoice",
      "version" => "1.0",
      "fields" => [
        {
          "key" => "invoice_number",
          "name" => "Invoice Number",
          "type" => "string",
          "required" => true,
          "active" => true,
          "position" => 1
        },
        {
          "key" => "customer",
          "name" => "Customer",
          "type" => "reference",
          "required" => true,
          "active" => true,
          "position" => 2
        },
        {
          "key" => "issue_date",
          "name" => "Issue Date",
          "type" => "date",
          "required" => true,
          "active" => true,
          "position" => 3
        },
        {
          "key" => "due_date",
          "name" => "Due Date",
          "type" => "date",
          "required" => true,
          "active" => true,
          "position" => 4
        },
        {
          "key" => "status",
          "name" => "Status",
          "type" => "select",
          "required" => true,
          "active" => true,
          "position" => 5,
          "options" => [
            { "value" => "draft", "label" => "Draft" },
            { "value" => "sent", "label" => "Sent" },
            { "value" => "paid", "label" => "Paid" },
            { "value" => "overdue", "label" => "Overdue" },
            { "value" => "cancelled", "label" => "Cancelled" }
          ]
        },
        {
          "key" => "subtotal",
          "name" => "Subtotal",
          "type" => "number",
          "required" => true,
          "active" => true,
          "position" => 6
        },
        {
          "key" => "tax",
          "name" => "Tax",
          "type" => "number",
          "required" => false,
          "active" => true,
          "position" => 7
        },
        {
          "key" => "total",
          "name" => "Total",
          "type" => "number",
          "required" => true,
          "active" => true,
          "position" => 8
        }
      ]
    }
  }
]

puts
puts "=============================================="
puts " Definition Library Seed"
puts "=============================================="
puts "Definitions: #{definitions.length}"
puts

definitions.each do |attributes|

  # ------------------------------------------------------------

  # IMPORTANT:

  #

  # ActiveRecord already owns the new_record? method.

  # Do NOT use a database attribute called `new_record` here.

  #

  # The model also requires `key`, so derive it from the slug.

  # ------------------------------------------------------------

  slug = attributes.fetch(:slug)

  attributes = attributes.merge(
    key: slug,
    library_new: true
  )

  # Never pass the legacy ActiveRecord-conflicting column.

  attributes.delete(:new_record)

  record = DefinitionLibraryDefinition.find_or_initialize_by(slug: slug)

  record.assign_attributes(attributes)

  unless record.save
    puts
    puts "FAILED: #{slug}"
    puts "Errors: #{record.errors.full_messages.join(', ')}"
    puts "Attributes:"
    puts record.attributes.inspect
    puts
    raise ActiveRecord::RecordInvalid, record
  end

  puts "✓ #{record.name.ljust(18)} #{record.slug}"
end

puts
puts "=============================================="
puts " Definition Library Ready"
puts "=============================================="
puts "Total records: #{DefinitionLibraryDefinition.count}"
puts "Active records: #{DefinitionLibraryDefinition.where(active: true).count}"
puts "Featured records: #{DefinitionLibraryDefinition.where(featured: true).count}"
puts "=============================================="
puts