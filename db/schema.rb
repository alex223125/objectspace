# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_09_18_184446) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "actions_simple_class_attributes", force: :cascade do |t|
    t.bigint "action_id", null: false
    t.bigint "simple_class_attribute_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_id"], name: "index_actions_attributes_on_action_id"
    t.index ["simple_class_attribute_id"], name: "index_actions_attributes_on_simple_class_attribute_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "algorithm_versions", force: :cascade do |t|
    t.string "title"
    t.text "solves_the_problem"
    t.text "sources"
    t.text "additional_information"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "algorithm_id"
    t.text "target_audience"
    t.virtual "searchable", type: :tsvector, as: "(((setweight(to_tsvector('english'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::\"char\") || setweight(to_tsvector('english'::regconfig, COALESCE(solves_the_problem, ''::text)), 'B'::\"char\")) || setweight(to_tsvector('english'::regconfig, COALESCE(sources, ''::text)), 'C'::\"char\")) || setweight(to_tsvector('english'::regconfig, COALESCE(additional_information, ''::text)), 'D'::\"char\"))", stored: true
    t.string "slug"
    t.text "description"
    t.index ["searchable"], name: "index_algorithm_versions_on_searchable", using: :gin
    t.index ["slug"], name: "index_algorithm_versions_on_slug", unique: true
  end

  create_table "algorithms", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_version_id"
    t.integer "visibility_status"
    t.text "source_page_description"
    t.virtual "searchable", type: :tsvector, as: "(setweight(to_tsvector('english'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::\"char\") || setweight(to_tsvector('english'::regconfig, COALESCE(source_page_description, ''::text)), 'B'::\"char\"))", stored: true
    t.integer "folder_id"
    t.string "ownerable_type", null: false
    t.bigint "ownerable_id", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "functional_type"
    t.integer "repository_id"
    t.index ["ownerable_type", "ownerable_id"], name: "index_algorithms_on_ownerable"
    t.index ["searchable"], name: "index_algorithms_on_searchable", using: :gin
  end

  create_table "article_versions", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.text "sources"
    t.text "additional_information"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "article_id"
    t.string "slug"
    t.index ["slug"], name: "index_article_versions_on_slug", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.integer "default_version_id"
    t.integer "visibility_status"
    t.text "source_page_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "folder_id"
    t.string "ownerable_type", null: false
    t.bigint "ownerable_id", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "repository_id"
    t.index ["ownerable_type", "ownerable_id"], name: "index_articles_on_ownerable"
  end

  create_table "class_container_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "class_container_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "class_container_desc_idx"
  end

  create_table "class_containers", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "simple_class_id"
    t.integer "framework_id"
    t.integer "parent_id"
  end

  create_table "conditions", force: :cascade do |t|
    t.string "title"
    t.text "instruction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "control_structure_id"
  end

  create_table "container_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "memberable_type"
    t.bigint "memberable_id"
    t.integer "class_container_id"
    t.index ["memberable_type", "memberable_id"], name: "index_container_members_on_memberable"
  end

  create_table "control_structures", force: :cascade do |t|
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "algorithm_version_id"
  end

  create_table "dashboards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "folder_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "folder_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "folder_desc_idx"
  end

  create_table "folders", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.integer "user_id"
    t.string "slug"
    t.integer "repository_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["slug"], name: "index_folders_on_slug", unique: true
  end

  create_table "frameworks", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "folder_id"
    t.string "ownerable_type", null: false
    t.bigint "ownerable_id", null: false
    t.string "slug"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "repository_id"
    t.index ["ownerable_type", "ownerable_id"], name: "index_frameworks_on_ownerable"
    t.index ["slug"], name: "index_frameworks_on_slug", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "improvements", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.text "sources"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "unit_id"
    t.virtual "searchable", type: :tsvector, as: "((setweight(to_tsvector('english'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::\"char\") || setweight(to_tsvector('english'::regconfig, COALESCE(content, ''::text)), 'B'::\"char\")) || setweight(to_tsvector('english'::regconfig, COALESCE(sources, ''::text)), 'C'::\"char\"))", stored: true
    t.integer "active_status"
    t.index ["searchable"], name: "index_improvements_on_searchable", using: :gin
  end

  create_table "interface_group_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "interface_group_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "interface_group_desc_idx"
  end

  create_table "interface_groups", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.integer "simple_class_id"
    t.integer "framework_id"
    t.integer "parent_id"
    t.integer "functional_type"
  end

  create_table "interface_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "memberable_type"
    t.bigint "memberable_id"
    t.integer "interface_group_id"
    t.integer "position"
    t.index ["memberable_type", "memberable_id"], name: "index_interface_members_on_memberable"
  end

  create_table "node_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "node_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "node_desc_idx"
  end

  create_table "nodes", force: :cascade do |t|
    t.string "type", null: false
    t.integer "position", null: false
    t.string "title"
    t.text "instruction"
    t.text "step_finish_check"
    t.text "solves_the_problem"
    t.text "sources"
    t.text "additional_information"
    t.text "note"
    t.integer "step_functional_type"
    t.integer "control_structure_id"
    t.integer "control_structure_functional_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "algorithm_version_id"
    t.string "technologiable_type"
    t.bigint "technologiable_id"
    t.integer "parent_id"
    t.text "description"
    t.index ["technologiable_type", "technologiable_id"], name: "index_nodes_on_technologiable"
  end

  create_table "repositories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "is_private"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "slug"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["slug"], name: "index_repositories_on_slug", unique: true
  end

  create_table "simple_class_attributes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "article_id"
    t.integer "simple_class_id"
    t.string "title"
    t.text "description"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "position"
  end

  create_table "simple_classes", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "instructionable_type"
    t.bigint "instructionable_id"
    t.integer "folder_id"
    t.string "ownerable_type", null: false
    t.bigint "ownerable_id", null: false
    t.string "slug"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "functional_type"
    t.text "source_page_description"
    t.integer "repository_id"
    t.index ["instructionable_type", "instructionable_id"], name: "index_simple_classes_on_instructionable"
    t.index ["ownerable_type", "ownerable_id"], name: "index_simple_classes_on_ownerable"
    t.index ["slug"], name: "index_simple_classes_on_slug", unique: true
  end

  create_table "step_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "step_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "step_desc_idx"
  end

  create_table "steps", force: :cascade do |t|
    t.string "title"
    t.text "instruction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "step_finish_check"
    t.text "solves_the_problem"
    t.text "sources"
    t.text "additional_information"
    t.integer "control_structure_id"
    t.integer "parent_id"
    t.text "note"
    t.integer "type"
    t.string "technologiable_type"
    t.bigint "technologiable_id"
    t.integer "position", null: false
    t.index ["technologiable_type", "technologiable_id"], name: "index_steps_on_technologiable"
  end

  create_table "substeps", force: :cascade do |t|
    t.string "title"
    t.text "note"
    t.integer "position"
    t.integer "step_id"
    t.string "substepable_type", null: false
    t.bigint "substepable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["substepable_type", "substepable_id"], name: "index_substeps_on_substepable"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "unit_usage_examples", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "sources"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "unit_id"
    t.boolean "is_for_all_unit_versions"
  end

  create_table "unit_version_improvements", force: :cascade do |t|
    t.bigint "unit_version_id", null: false
    t.bigint "improvement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["improvement_id"], name: "index_unit_version_improvements_on_improvement_id"
    t.index ["unit_version_id"], name: "index_unit_version_improvements_on_unit_version_id"
  end

  create_table "unit_version_unit_usage_examples", force: :cascade do |t|
    t.bigint "unit_version_id", null: false
    t.bigint "unit_usage_example_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_usage_example_id"], name: "index_unit_version_unit_usage_examples_on_unit_usage_example_id"
    t.index ["unit_version_id"], name: "index_unit_version_unit_usage_examples_on_unit_version_id"
  end

  create_table "unit_versions", force: :cascade do |t|
    t.string "title"
    t.text "instruction"
    t.text "solves_the_problem"
    t.text "sources"
    t.text "additional_information"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "unit_id"
    t.text "target_audience"
    t.virtual "searchable", type: :tsvector, as: "(((setweight(to_tsvector('english'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::\"char\") || setweight(to_tsvector('english'::regconfig, COALESCE(instruction, ''::text)), 'B'::\"char\")) || setweight(to_tsvector('english'::regconfig, COALESCE(solves_the_problem, ''::text)), 'C'::\"char\")) || setweight(to_tsvector('english'::regconfig, COALESCE(sources, ''::text)), 'D'::\"char\"))", stored: true
    t.string "slug"
    t.text "description"
    t.index ["searchable"], name: "index_unit_versions_on_searchable", using: :gin
    t.index ["slug"], name: "index_unit_versions_on_slug", unique: true
  end

  create_table "units", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "visibility_status"
    t.integer "default_version_id"
    t.text "source_page_description"
    t.virtual "searchable", type: :tsvector, as: "(setweight(to_tsvector('english'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::\"char\") || setweight(to_tsvector('english'::regconfig, COALESCE(source_page_description, ''::text)), 'B'::\"char\"))", stored: true
    t.integer "folder_id"
    t.string "ownerable_type", null: false
    t.bigint "ownerable_id", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "repository_id"
    t.index ["ownerable_type", "ownerable_id"], name: "index_units_on_ownerable"
    t.index ["searchable"], name: "index_units_on_searchable", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "tos_agreement"
    t.string "uid"
    t.string "avatar_url"
    t.string "provider"
    t.text "biography"
    t.boolean "is_email_public"
    t.text "website"
    t.text "company"
    t.text "location"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "actions_simple_class_attributes", "interface_members", column: "action_id"
  add_foreign_key "actions_simple_class_attributes", "simple_class_attributes"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "taggings", "tags"
  add_foreign_key "unit_version_improvements", "improvements"
  add_foreign_key "unit_version_improvements", "unit_versions"
  add_foreign_key "unit_version_unit_usage_examples", "unit_usage_examples"
  add_foreign_key "unit_version_unit_usage_examples", "unit_versions"
end
