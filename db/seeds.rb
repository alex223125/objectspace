# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)


### REINDEX ELASTICSEARCH
Articles::Article.reindex
Units::Unit.reindex
Algorithms::Algorithm.reindex
SimpleClasses::SimpleClass.reindex
Frameworks::Framework.reindex





require_relative "seeds/definition_templates"

puts "Seeding Definition Library..."

DEFINITION_LIBRARY.each do |definition_data|

  definition = Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionTemplate.find_or_initialize_by(
    external_id: definition_data[:id]
  )

  definition.assign_attributes(
    name: definition_data[:name],
    slug: definition_data[:id],
    category: definition_data[:category],
    description: definition_data[:description],
    icon: definition_data[:icon],
    color: definition_data[:color],
    featured: definition_data.fetch(:featured, false),
    is_new: definition_data.fetch(:new, false),
    active: true,
    status: "published",
    tags: definition_data.fetch(:tags, []),
    metadata: {
      "source" => "system",
      "seeded" => true
    }
  )

  definition.save!

  definition.versions
            .where(version: 1)
            .first_or_create!(
              status: "published",
              definition: {
                "fields" => definition_data[:fields]
              },
              metadata: {
                "source" => "system_seed"
              },
              published_at: Time.current
            )

  puts "  ✓ #{definition.name}"
end

puts "Definition Library seeded."
puts "#{Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionTemplate.count} definitions available."


# frozen_string_literal: true

# Main application seed file.

load Rails.root.join("db", "seeds", "definition_library.rb")


Dir[Rails.root.join("db/seeds/**/*.rb")]
  .sort
  .each do |seed_file|
  puts
  puts "============================================================"
  puts "Running seed: #{seed_file}"
  puts "============================================================"

  load seed_file
end



















# frozen_string_literal: true

DefinitionLibraryDefinition =
  Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionLibraryDefinition

definitions = [
  {
    name: "Person",
    slug: "person",
    description: "A production-ready person profile with identity and contact information.",
    category: "People",
    icon: "👤",
    tags: ["people", "identity", "contact", "profile"],
    popularity: 98,
    featured: true,
    active: true,
    new_record: false,
    version: "1.0",
    definition_json: {
      "entity" => "Person",
      "version" => "1.0",
      "fields" => [
        {
          "name" => "first_name",
          "label" => "First Name",
          "type" => "string",
          "required" => true,
          "active" => true
        },
        {
          "name" => "last_name",
          "label" => "Last Name",
          "type" => "string",
          "required" => true,
          "active" => true
        },
        {
          "name" => "email",
          "label" => "Email",
          "type" => "email",
          "required" => true,
          "active" => true
        },
        {
          "name" => "phone",
          "label" => "Phone",
          "type" => "string",
          "required" => false,
          "active" => true
        },
        {
          "name" => "date_of_birth",
          "label" => "Date of Birth",
          "type" => "date",
          "required" => false,
          "active" => true
        }
      ]
    }
  },

  {
    name: "Company",
    slug: "company",
    description: "A structured company profile suitable for CRM and business workflows.",
    category: "Business",
    icon: "🏢",
    tags: ["company", "business", "crm", "organization"],
    popularity: 96,
    featured: true,
    active: true,
    new_record: false,
    version: "1.0",
    definition_json: {
      "entity" => "Company",
      "version" => "1.0",
      "fields" => [
        {
          "name" => "name",
          "label" => "Company Name",
          "type" => "string",
          "required" => true,
          "active" => true
        },
        {
          "name" => "legal_name",
          "label" => "Legal Name",
          "type" => "string",
          "required" => false,
          "active" => true
        },
        {
          "name" => "website",
          "label" => "Website",
          "type" => "url",
          "required" => false,
          "active" => true
        },
        {
          "name" => "email",
          "label" => "Email",
          "type" => "email",
          "required" => false,
          "active" => true
        },
        {
          "name" => "industry",
          "label" => "Industry",
          "type" => "select",
          "required" => false,
          "active" => true
        },
        {
          "name" => "employees",
          "label" => "Employees",
          "type" => "integer",
          "required" => false,
          "active" => true
        }
      ]
    }
  },

  {
    name: "Product",
    slug: "product",
    description: "Flexible product definition for catalogs, commerce and inventory systems.",
    category: "Commerce",
    icon: "📦",
    tags: ["product", "commerce", "inventory", "catalog"],
    popularity: 94,
    featured: true,
    active: true,
    new_record: false,
    version: "1.0",
    definition_json: {
      "entity" => "Product",
      "version" => "1.0",
      "fields" => [
        {
          "name" => "name",
          "label" => "Product Name",
          "type" => "string",
          "required" => true,
          "active" => true
        },
        {
          "name" => "sku",
          "label" => "SKU",
          "type" => "string",
          "required" => true,
          "active" => true
        },
        {
          "name" => "description",
          "label" => "Description",
          "type" => "text",
          "required" => false,
          "active" => true
        },
        {
          "name" => "price",
          "label" => "Price",
          "type" => "number",
          "required" => true,
          "active" => true
        },
        {
          "name" => "currency",
          "label" => "Currency",
          "type" => "string",
          "required" => true,
          "active" => true
        },
        {
          "name" => "active",
          "label" => "Active",
          "type" => "boolean",
          "required" => true,
          "active" => true
        }
      ]
    }
  },

  {
    name: "Address",
    slug: "address",
    description: "Reusable postal address structure for customers, companies and locations.",
    category: "Location",
    icon: "📍",
    tags: ["address", "location", "postal", "geography"],
    popularity: 89,
    featured: false,
    active: true,
    new_record: false,
    version: "1.0",
    definition_json: {
      "entity" => "Address",
      "version" => "1.0",
      "fields" => [
        {
          "name" => "address_line_1",
          "label" => "Address Line 1",
          "type" => "string",
          "required" => true,
          "active" => true
        },
        {
          "name" => "address_line_2",
          "label" => "Address Line 2",
          "type" => "string",
          "required" => false,
          "active" => true
        },
        {
          "name" => "city",
          "label" => "City",
          "type" => "string",
          "required" => true,
          "active" => true
        },
        {
          "name" => "postal_code",
          "label" => "Postal Code",
          "type" => "string",
          "required" => true,
          "active" => true
        },
        {
          "name" => "country",
          "label" => "Country",
          "type" => "string",
          "required" => true,
          "active" => true
        }
      ]
    }
  },

  {
    name: "Event",
    slug: "event",
    description: "Event structure for meetings, appointments, launches and scheduled activities.",
    category: "Operations",
    icon: "📅",
    tags: ["event", "calendar", "appointment", "schedule"],
    popularity: 87,
    featured: false,
    active: true,
    new_record: true,
    version: "1.0",
    definition_json: {
      "entity" => "Event",
      "version" => "1.0",
      "fields" => [
        {
          "name" => "title",
          "label" => "Title",
          "type" => "string",
          "required" => true,
          "active" => true
        },
        {
          "name" => "description",
          "label" => "Description",
          "type" => "text",
          "required" => false,
          "active" => true
        },
        {
          "name" => "starts_at",
          "label" => "Starts At",
          "type" => "datetime",
          "required" => true,
          "active" => true
        },
        {
          "name" => "ends_at",
          "label" => "Ends At",
          "type" => "datetime",
          "required" => false,
          "active" => true
        },
        {
          "name" => "location",
          "label" => "Location",
          "type" => "string",
          "required" => false,
          "active" => true
        }
      ]
    }
  },

  {
    name: "Order",
    slug: "order",
    description: "Commerce order structure with customer, status and financial information.",
    category: "Commerce",
    icon: "🧾",
    tags: ["order", "commerce", "checkout", "sales"],
    popularity: 91,
    featured: true,
    active: true,
    new_record: false,
    version: "1.0",
    definition_json: {
      "entity" => "Order",
      "version" => "1.0",
      "fields" => [
        {
          "name" => "order_number",
          "label" => "Order Number",
          "type" => "string",
          "required" => true,
          "active" => true
        },
        {
          "name" => "customer",
          "label" => "Customer",
          "type" => "reference",
          "required" => true,
          "active" => true
        },
        {
          "name" => "status",
          "label" => "Status",
          "type" => "select",
          "required" => true,
          "active" => true
        },
        {
          "name" => "total",
          "label" => "Total",
          "type" => "number",
          "required" => true,
          "active" => true
        },
        {
          "name" => "currency",
          "label" => "Currency",
          "type" => "string",
          "required" => true,
          "active" => true
        },
        {
          "name" => "ordered_at",
          "label" => "Ordered At",
          "type" => "datetime",
          "required" => true,
          "active" => true
        }
      ]
    }
  }
]

definitions.each do |attributes|
  definition = DefinitionLibraryDefinition.find_or_initialize_by(
    slug: attributes[:slug]
  )

  definition.assign_attributes(attributes)
  definition.save!
end

puts "Seeded #{definitions.length} definition library definitions."