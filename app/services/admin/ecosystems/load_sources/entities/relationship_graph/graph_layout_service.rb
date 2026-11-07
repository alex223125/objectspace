
# frozen_string_literal: true

module Admin
  module Ecosystems
    module LoadSources
      module Entities
        module RelationshipGraph
          class GraphLayoutService
            DEFAULT_WIDTH = 1_000
            DEFAULT_HEIGHT = 650
            PADDING = 70
            NODE_RADIUS = 18

            VALID_LAYOUTS = %w[circle grid radial].freeze

            def initialize(
              nodes:,
              edges: [],
              width: DEFAULT_WIDTH,
              height: DEFAULT_HEIGHT,
              layout: "circle",
              root_id: nil
            )
              @nodes = Array(nodes)
              @edges = Array(edges)
              @width = bounded_dimension(width)
              @height = bounded_dimension(height)
              @layout = layout.to_s
              @root_id = root_id.to_s if root_id
            end

            def call
              validate_layout!

              normalized_nodes = @nodes.map do |node|
                {
                  id: read(node, :id).to_s,
                  name: read(node, :name).presence || "Unnamed entity"
                }
              end

              positions = case @layout
                          when "grid"
                            grid_positions(normalized_nodes)
                          when "radial"
                            radial_positions(normalized_nodes)
                          else
                            circle_positions(normalized_nodes)
                          end

              {
                layout: @layout,
                width: @width,
                height: @height,
                nodes: normalized_nodes.map do |node|
                  node.merge(positions.fetch(node[:id]))
                end,
                edges: layout_edges(positions)
              }
            end

            private

            def circle_positions(nodes)
              count = nodes.length
              return {} if count.zero?

              center_x = @width / 2.0
              center_y = @height / 2.0
              radius = [[
                          [@width, @height].min / 2.0 - PADDING,
                          40
                        ].max, 10_000].min

              nodes.each_with_index.each_with_object({}) do |(node, index), result|
                angle = (2.0 * Math::PI * index / count) - Math::PI / 2.0

                result[node[:id]] = {
                  x: round(center_x + radius * Math.cos(angle)),
                  y: round(center_y + radius * Math.sin(angle))
                }
              end
            end

            def grid_positions(nodes)
              count = nodes.length
              return {} if count.zero?

              columns = Math.sqrt(count).ceil
              rows = (count.to_f / columns).ceil

              usable_width = [@width - 2 * PADDING, 1].max
              usable_height = [@height - 2 * PADDING, 1].max

              nodes.each_with_index.each_with_object({}) do |(node, index), result|
                column = index % columns
                row = index / columns

                x = columns == 1 ? @width / 2.0 :
                      PADDING + column * usable_width / (columns - 1).to_f

                y = rows == 1 ? @height / 2.0 :
                      PADDING + row * usable_height / (rows - 1).to_f

                result[node[:id]] = { x: round(x), y: round(y) }
              end
            end

            def radial_positions(nodes)
              return {} if nodes.empty?

              root = nodes.find { |node| node[:id] == @root_id } || nodes.first
              remaining = nodes.reject { |node| node[:id] == root[:id] }

              center = {
                x: round(@width / 2.0),
                y: round(@height / 2.0)
              }

              result = { root[:id] => center }
              return result if remaining.empty?

              radius = [[
                          [@width, @height].min / 2.0 - PADDING,
                          40
                        ].max, 10_000].min

              remaining.each_with_index do |node, index|
                angle = (2.0 * Math::PI * index / remaining.length) -
                  Math::PI / 2.0

                result[node[:id]] = {
                  x: round(center[:x] + radius * Math.cos(angle)),
                  y: round(center[:y] + radius * Math.sin(angle))
                }
              end

              result
            end

            def layout_edges(positions)
              @edges.filter_map do |edge|
                source = read(edge, :source_entity_id) ||
                  read(edge, :source_id) ||
                  read(edge, :from_id)

                target = read(edge, :target_entity_id) ||
                  read(edge, :target_id) ||
                  read(edge, :to_id)

                next unless source && target

                source = source.to_s
                target = target.to_s

                next unless positions.key?(source) && positions.key?(target)

                {
                  id: read(edge, :id)&.to_s,
                  source_id: source,
                  target_id: target,
                  source: positions[source],
                  target: positions[target],
                  relationship_type:
                    read(edge, :relationship_type).presence || "related"
                }
              end
            end

            def validate_layout!
              return if VALID_LAYOUTS.include?(@layout)

              raise ArgumentError,
                    "layout must be circle, grid, or radial"
            end

            def bounded_dimension(value)
              dimension = Integer(value.to_s, 10)

              unless dimension.between?(200, 4_000)
                raise ArgumentError,
                      "canvas dimensions must be between 200 and 4000"
              end

              dimension
            rescue ArgumentError, TypeError
              raise ArgumentError, "invalid canvas dimension"
            end

            def round(value)
              value.round(2)
            end

            def read(record, field)
              if record.respond_to?(:key?)
                return record[field] if record.key?(field)
                return record[field.to_s] if record.key?(field.to_s)
              end

              record.public_send(field) if record.respond_to?(field)
            end
          end
        end
      end
    end
  end
end