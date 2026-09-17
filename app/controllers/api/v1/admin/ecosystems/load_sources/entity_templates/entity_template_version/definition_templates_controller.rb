# frozen_string_literal: true

module Api
  module V1
    module Admin
      module Ecosystems
        module LoadSources
          module EntityTemplates
            module EntityTemplateVersion
              class DefinitionTemplatesController < ApplicationController
                before_action :set_definition_template, only: :show

                def index
                  Rails.logger.info(
                    "[DefinitionLibrary API] index:start " \
                      "controller=#{self.class.name}"
                  )

                  definitions = definition_scope

                  Rails.logger.info(
                    "[DefinitionLibrary API] index:database " \
                      "count=#{definitions.count}"
                  )

                  render json: {
                    definitions: definitions.map do |definition|
                      serialize(definition)
                    end,
                    meta: {
                      count: definitions.length,
                      source: "database",
                      api_version: "v1"
                    }
                  }
                rescue StandardError => e
                  Rails.logger.error(
                    "[DefinitionLibrary API] index:error " \
                      "#{e.class}: #{e.message}"
                  )

                  Rails.logger.error(
                    e.backtrace.first(10).join("\n")
                  )

                  render json: {
                    error: "Unable to load definition library.",
                    code: "definition_library_load_failed"
                  }, status: :internal_server_error
                end

                def show
                  Rails.logger.info(
                    "[DefinitionLibrary API] show " \
                      "id=#{@definition_template.id}"
                  )

                  render json: {
                    definition: serialize(@definition_template)
                  }
                rescue StandardError => e
                  Rails.logger.error(
                    "[DefinitionLibrary API] show:error " \
                      "#{e.class}: #{e.message}"
                  )

                  render json: {
                    error: "Unable to load definition.",
                    code: "definition_load_failed"
                  }, status: :internal_server_error
                end

                private

                def definition_scope
                  scope =
                    ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionLibraryDefinition
                      .all

                  scope = scope.where(active: true) if column_exists?(:active)

                  apply_category_filter(scope)
                  apply_featured_filter(scope)
                  apply_new_filter(scope)

                  apply_sort(scope)
                end

                def set_definition_template
                  @definition_template =
                    ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionLibraryDefinition
                      .find(params[:id])
                end

                def serialize(definition)
                  Rails.logger.info(
                    "[DefinitionLibrary API] serialize " \
                      "id=#{definition.id} " \
                      "name=#{definition.name.inspect} " \
                      "fields=#{definition.respond_to?(:fields) ? definition.fields.inspect : 'NO_FIELDS_METHOD'} " \
                      "definition=#{definition.respond_to?(:definition) ? definition.definition.inspect : 'NO_DEFINITION_METHOD'}"
                  )

                  Api::V1::Admin::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersion::DefinitionTemplateSerializer
                    .new(definition)
                    .as_json
                end

                def apply_category_filter(scope)
                  category = params[:category].to_s.strip

                  return scope if category.blank?
                  return scope if category.casecmp("all").zero?

                  return scope unless column_exists?(:category)

                  scope.where(category: category)
                end

                def apply_featured_filter(scope)
                  return scope unless params[:featured].present?
                  return scope unless column_exists?(:featured)

                  value = ActiveModel::Type::Boolean.new.cast(
                    params[:featured]
                  )

                  scope.where(featured: value)
                end

                def apply_new_filter(scope)
                  return scope unless params[:new].present?
                  return scope unless column_exists?(:new)

                  value = ActiveModel::Type::Boolean.new.cast(
                    params[:new]
                  )

                  scope.where(new: value)
                end

                def apply_sort(scope)
                  sort = params[:sort].to_s

                  case sort
                  when "name_asc"
                    scope = scope.order(Arel.sql("LOWER(name) ASC")) if column_exists?(:name)

                  when "name_desc"
                    scope = scope.order(Arel.sql("LOWER(name) DESC")) if column_exists?(:name)

                  when "popularity_desc"
                    scope = scope.order(popularity: :desc) if column_exists?(:popularity)

                  when "newest"
                    if column_exists?(:created_at)
                      scope = scope.order(created_at: :desc)
                    end

                  when "featured"
                    if column_exists?(:featured)
                      scope = scope.order(featured: :desc)
                    end

                    scope =
                      scope.order(
                        popularity: :desc
                      ) if column_exists?(:popularity)

                  else
                    if column_exists?(:featured)
                      scope = scope.order(featured: :desc)
                    end

                    if column_exists?(:popularity)
                      scope = scope.order(popularity: :desc)
                    end

                    if column_exists?(:name)
                      scope = scope.order(Arel.sql("LOWER(name) ASC"))
                    end
                  end

                  scope
                end

                def column_exists?(column)
                  ::Ecosystems::LoadSources::EntityTemplates::EntityTemplateVersions::DefinitionLibraryDefinition
                    .column_names
                    .include?(column.to_s)
                end
              end
            end
          end
        end
      end
    end
  end
end