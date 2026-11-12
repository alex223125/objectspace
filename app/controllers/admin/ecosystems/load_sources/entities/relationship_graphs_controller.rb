require "set"
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        class RelationshipGraphsController < ApplicationController
          before_action :authenticate_user!, if: :devise_authentication_available?

          rescue_from ActionController::ParameterMissing,
                      with: :render_bad_request

          rescue_from ActiveRecord::RecordNotFound,
                      with: :render_not_found


          def index
            respond_to do |format|
              format.html do
                @graph_payload =
                  ::Admin::Ecosystems::LoadSources::Entities::
                      EntityRelationship::RelationshipGraphService.new(
                    limit: 100,
                    depth: 1
                  ).call

                content = render_to_string(
                  template: "admin/ecosystems/load_sources/entities/relationship_graphs/index",
                  layout: false
                )

                render(
                  template: "admin/ecosystems/load_sources/entity_templates/layout/entity_templates_layout",
                  layout: false,
                  locals: { content: content }
                )
              end

              format.json do
                payload = @graph_payload || {}

                payload = payload.deep_stringify_keys if payload.respond_to?(:deep_stringify_keys)

                query = params[:query].to_s.strip.downcase

                if query.present?
                  nodes = Array(payload["nodes"]).select do |node|
                    %w[id name slug summary status workflow_state entity_type_id].any? do |field|
                      node[field].to_s.downcase.include?(query)
                    end
                  end

                  matching_ids = nodes.map { |node| node["id"].to_s }.to_set

                  edges = Array(payload["edges"]).select do |edge|
                    source = edge["source"] || edge["source_id"] || edge["source_entity_id"]
                    target = edge["target"] || edge["target_id"] || edge["target_entity_id"]

                    matching_ids.include?(source.to_s) &&
                      matching_ids.include?(target.to_s)
                  end

                  payload["nodes"] = nodes
                  payload["edges"] = edges
                  payload["meta"] ||= {}
                  payload["meta"]["node_count"] = nodes.size
                  payload["meta"]["edge_count"] = edges.size
                end

                render json: payload, status: :ok
              end
            end
          end

          private

          def graph_api_path
            helpers.admin_ecosystems_load_sources_entities_graph_api_path
          rescue NoMethodError
            nil
          end

          def devise_authentication_available?
            respond_to?(:authenticate_user!, true)
          end

          def render_bad_request(exception)
            render json: {
              error: "Invalid request parameters.",
              details: exception.message
            }, status: :bad_request
          end

          def render_not_found
            respond_to do |format|
              format.html do
                render(
                  template: "admin/ecosystems/load_sources/entities/relationship_graphs/_error_state",
                  status: :not_found
                )
              end

              format.json do
                render json: {
                  error: "The requested graph resource was not found."
                }, status: :not_found
              end
            end
          end
        end
      end
    end
  end
end