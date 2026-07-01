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

ActiveRecord::Schema[7.0].define(version: 2026_06_30_021516) do
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

  create_table "algorithm_reports", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "algorithm_version_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "slug"
    t.integer "creator_id"
    t.integer "reports_repository_id"
    t.integer "folder_id"
    t.string "ownerable_type"
    t.integer "ownerable_id"
    t.integer "completion_state"
    t.integer "logging_step_id"
    t.index ["slug"], name: "index_algorithm_reports_on_slug", unique: true
  end

  create_table "algorithm_trees", force: :cascade do |t|
    t.string "algorithm_version_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "display_type", default: 1, null: false
    t.string "whole_tree_content_words_amount"
    t.integer "original_algorithm_version_version_number"
    t.integer "backend_storage_type_id"
    t.integer "original_algorithm_version_id"
    t.integer "duplicate_algorithm_verion_version_number"
    t.bigint "algorithm_tree_id", default: 1, null: false
    t.integer "interactivity_type_id", default: 1
    t.integer "wizard_creation_stage_id", default: 1
    t.string "print_title", limit: 60
    t.string "short_print_description", limit: 160
    t.string "cached_qr_short_token", limit: 12
    t.index ["algorithm_tree_id"], name: "index_algorithm_versions_on_algorithm_tree_id"
    t.index ["cached_qr_short_token"], name: "index_algorithm_versions_on_cached_qr_short_token", unique: true
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
    t.integer "functional_type", null: false
    t.integer "repository_id"
    t.integer "creator_id"
    t.integer "framework_interface_id"
    t.integer "simple_class_interface_id"
    t.integer "wizard_creation_stage_id", default: 1
    t.index ["ownerable_type", "ownerable_id"], name: "index_algorithms_on_ownerable"
    t.index ["searchable"], name: "index_algorithms_on_searchable", using: :gin
  end

  create_table "article_version_improvements", force: :cascade do |t|
    t.bigint "article_version_id", null: false
    t.bigint "improvement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_version_id"], name: "index_article_version_improvements_on_article_version_id"
    t.index ["improvement_id"], name: "index_article_version_improvements_on_improvement_id"
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
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
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
    t.integer "creator_id"
    t.string "slug"
    t.index ["ownerable_type", "ownerable_id"], name: "index_articles_on_ownerable"
    t.index ["slug"], name: "index_articles_on_slug", unique: true
  end

  create_table "articles_simple_class_attributes", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.bigint "simple_class_attribute_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_articles_attributes_on_article_id"
    t.index ["simple_class_attribute_id"], name: "index_articles_attributes_on_simple_class_attribute_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.string "attachable_type", null: false
    t.integer "attachable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "node_id"
    t.integer "unit_version_id"
    t.integer "article_version_id"
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable"
  end

  create_table "cheat_sheet_group_sections", force: :cascade do |t|
    t.string "sectionable_type", null: false
    t.bigint "sectionable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cheat_sheet_group_version_id"
    t.index ["sectionable_type", "sectionable_id"], name: "index_cheat_sheet_group_sections_on_sectionable"
  end

  create_table "cheat_sheet_group_versions", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cheat_sheet_group_id"
    t.string "slug"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["slug"], name: "index_cheat_sheet_group_versions_on_slug", unique: true
  end

  create_table "cheat_sheet_groups", force: :cascade do |t|
    t.string "title"
    t.text "source_page_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_version_id"
    t.string "ownerable_type"
    t.integer "ownerable_id"
    t.integer "folder_id"
    t.integer "repository_id"
    t.integer "creator_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
  end

  create_table "cheat_sheet_versions", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cheat_sheet_id"
    t.string "slug"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["slug"], name: "index_cheat_sheet_versions_on_slug", unique: true
  end

  create_table "cheat_sheets", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "folder_id"
    t.integer "repository_id"
    t.integer "visibility_status"
    t.integer "default_version_id"
    t.text "source_page_description"
    t.string "ownerable_type"
    t.integer "ownerable_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "creator_id"
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
    t.integer "creator_id"
    t.integer "related_simple_class_id"
    t.integer "functional_type", null: false
    t.string "slug"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "related_framework_id"
    t.integer "belongs_to_structure_type"
    t.index ["slug"], name: "index_class_containers_on_slug", unique: true
  end

  create_table "comment_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "comment_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "comment_desc_idx"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
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
    t.integer "reference_type", null: false
    t.string "slug"
    t.string "title"
    t.index ["memberable_type", "memberable_id"], name: "index_container_members_on_memberable"
    t.index ["slug"], name: "index_container_members_on_slug", unique: true
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
    t.string "ownerable_type"
    t.integer "ownerable_id"
    t.integer "reports_repository_id"
    t.index ["slug"], name: "index_folders_on_slug", unique: true
  end

  create_table "framework_folder_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "framework_folder_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "framework_folder_desc_idx"
  end

  create_table "framework_folders", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "framework_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "slug"
    t.integer "parent_id"
    t.integer "creator_id"
    t.integer "functional_type"
    t.integer "related_framework_id"
    t.index ["slug"], name: "index_framework_folders_on_slug", unique: true
  end

  create_table "framework_interfaces", force: :cascade do |t|
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "framework_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
  end

  create_table "framework_members", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "framework_folder_id"
    t.integer "reference_type"
    t.string "framework_memberable_type", null: false
    t.bigint "framework_memberable_id", null: false
    t.string "slug"
    t.text "description"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["framework_memberable_type", "framework_memberable_id"], name: "index_framework_members_on_framework_memberable"
    t.index ["slug"], name: "index_framework_members_on_slug", unique: true
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
    t.integer "creator_id"
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
    t.virtual "searchable", type: :tsvector, as: "((setweight(to_tsvector('english'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::\"char\") || setweight(to_tsvector('english'::regconfig, COALESCE(content, ''::text)), 'B'::\"char\")) || setweight(to_tsvector('english'::regconfig, COALESCE(sources, ''::text)), 'C'::\"char\"))", stored: true
    t.integer "active_status"
    t.string "slug"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "improvable_type", null: false
    t.bigint "improvable_id", null: false
    t.string "ownerable_type", null: false
    t.bigint "ownerable_id", null: false
    t.integer "creator_id"
    t.integer "active_status_type", null: false
    t.index ["improvable_type", "improvable_id"], name: "index_improvements_on_improvable"
    t.index ["ownerable_type", "ownerable_id"], name: "index_improvements_on_ownerable"
    t.index ["searchable"], name: "index_improvements_on_searchable", using: :gin
    t.index ["slug"], name: "index_improvements_on_slug", unique: true
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
    t.integer "functional_type", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "class_container_id"
    t.integer "related_simple_class_id"
    t.integer "creator_id"
    t.string "slug"
    t.integer "related_class_container_id"
    t.integer "related_framework_id"
    t.index ["slug"], name: "index_interface_groups_on_slug", unique: true
  end

  create_table "interface_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "memberable_type"
    t.bigint "memberable_id"
    t.integer "interface_group_id"
    t.integer "position"
    t.integer "reference_type", null: false
    t.string "slug"
    t.string "title"
    t.index ["memberable_type", "memberable_id"], name: "index_interface_members_on_memberable"
    t.index ["slug"], name: "index_interface_members_on_slug", unique: true
  end

  create_table "introduction_steps", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "algorithm_version_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "slug"
    t.index ["slug"], name: "index_introduction_steps_on_slug", unique: true
  end

  create_table "leafe_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "leafe_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "leafe_desc_idx"
  end

  create_table "leaves", force: :cascade do |t|
    t.string "node_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.integer "position", null: false
    t.integer "algorithm_tree_id", null: false
    t.string "referencable_type"
    t.bigint "referencable_id"
    t.text "node_description"
    t.integer "referenced_step_functional_type"
    t.integer "referenced_control_structure_functional_type"
    t.text "node_note"
    t.integer "related_algorithm_version_id"
    t.integer "algorithm_version_id"
    t.index ["referencable_type", "referencable_id"], name: "index_leaves_on_referencable"
  end

  create_table "link_attachments", force: :cascade do |t|
    t.string "linkable_type", null: false
    t.bigint "linkable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "note_id"
    t.index ["linkable_type", "linkable_id"], name: "index_link_attachments_on_linkable"
  end

  create_table "logging_introduction_steps", force: :cascade do |t|
    t.integer "introduction_step_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "slug"
    t.integer "algorithm_report_id"
    t.index ["slug"], name: "index_logging_introduction_steps_on_slug", unique: true
  end

  create_table "logging_node_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "logging_node_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "logging_node_desc_idx"
  end

  create_table "logging_nodes", force: :cascade do |t|
    t.string "type"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "slug"
    t.text "content"
    t.integer "parent_id"
    t.integer "control_structure_id"
    t.integer "control_structure_functional_type"
    t.integer "algorithm_version_id"
    t.integer "related_algorithm_version_id"
    t.integer "original_node_id"
    t.string "title"
    t.integer "algorithm_report_id"
    t.integer "step_functional_type"
    t.integer "logging_step_included_content_type"
    t.index ["slug"], name: "index_logging_nodes_on_slug", unique: true
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
    t.string "slug"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "related_algorithm_version_id"
    t.integer "backend_storage_type_id"
    t.integer "original_node_id"
    t.index ["slug"], name: "index_nodes_on_slug", unique: true
    t.index ["technologiable_type", "technologiable_id"], name: "index_nodes_on_technologiable"
  end

  create_table "notes", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cheat_sheet_version_id"
    t.text "content"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.string "permissionable_type", null: false
    t.bigint "permissionable_id", null: false
    t.string "actorable_type", null: false
    t.bigint "actorable_id", null: false
    t.integer "allowed_action_type", null: false
    t.integer "source_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actorable_type", "actorable_id"], name: "index_permissions_on_actorable"
    t.index ["permissionable_type", "permissionable_id"], name: "index_permissions_on_permissionable"
  end

  create_table "reports_repositories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ownerable_type"
    t.integer "ownerable_id"
    t.integer "functional_type"
    t.string "title"
    t.text "description"
    t.string "slug"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.boolean "is_private"
    t.index ["slug"], name: "index_reports_repositories_on_slug", unique: true
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
    t.string "ownerable_type"
    t.integer "ownerable_id"
    t.integer "functional_type"
    t.index ["slug"], name: "index_repositories_on_slug", unique: true
  end

  create_table "simple_class_attributes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "simple_class_id"
    t.string "title"
    t.text "description"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "position"
    t.string "slug"
    t.integer "class_container_id"
    t.integer "related_simple_class_id"
    t.integer "creator_id"
    t.string "ownerable_type"
    t.integer "ownerable_id"
    t.index ["slug"], name: "index_simple_class_attributes_on_slug", unique: true
  end

  create_table "simple_class_interfaces", force: :cascade do |t|
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "simple_class_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
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
    t.integer "functional_type", null: false
    t.text "source_page_description"
    t.integer "repository_id"
    t.integer "creator_id"
    t.integer "related_framework_id"
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
    t.index ["position"], name: "index_steps_on_position", unique: true
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

  create_table "tenant_qr_assets", force: :cascade do |t|
    t.bigint "algorithm_version_id", null: false
    t.string "lookup_hash", null: false
    t.text "cached_svg_matrix"
    t.string "configured_foreground", default: "#4F46E5"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["algorithm_version_id"], name: "index_tenant_qr_assets_on_algorithm_version_id"
    t.index ["lookup_hash"], name: "index_tenant_qr_assets_on_lookup_hash", unique: true
  end

  create_table "unit_version_improvements", force: :cascade do |t|
    t.bigint "unit_version_id", null: false
    t.bigint "improvement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["improvement_id"], name: "index_unit_version_improvements_on_improvement_id"
    t.index ["unit_version_id"], name: "index_unit_version_improvements_on_unit_version_id"
  end

  create_table "unit_version_usage_examples", force: :cascade do |t|
    t.bigint "unit_version_id", null: false
    t.bigint "usage_example_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_version_id"], name: "index_unit_version_usage_examples_on_unit_version_id"
    t.index ["usage_example_id"], name: "index_unit_version_usage_examples_on_usage_example_id"
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
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
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
    t.integer "creator_id"
    t.string "slug"
    t.index ["ownerable_type", "ownerable_id"], name: "index_units_on_ownerable"
    t.index ["searchable"], name: "index_units_on_searchable", using: :gin
    t.index ["slug"], name: "index_units_on_slug", unique: true
  end

  create_table "usage_examples", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.text "sources"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_for_all_versions", default: false
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
    t.integer "reports_repository_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "actions_simple_class_attributes", "interface_members", column: "action_id"
  add_foreign_key "actions_simple_class_attributes", "simple_class_attributes"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "algorithm_versions", "algorithm_trees"
  add_foreign_key "article_version_improvements", "article_versions"
  add_foreign_key "article_version_improvements", "improvements"
  add_foreign_key "articles_simple_class_attributes", "articles"
  add_foreign_key "articles_simple_class_attributes", "simple_class_attributes"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tenant_qr_assets", "algorithm_versions"
  add_foreign_key "unit_version_improvements", "improvements"
  add_foreign_key "unit_version_improvements", "unit_versions"
  add_foreign_key "unit_version_usage_examples", "unit_versions"
  add_foreign_key "unit_version_usage_examples", "usage_examples"
end
