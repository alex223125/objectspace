# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class Node
          attr_reader \
            :path,
            :key,
            :status,
            :old_value,
            :new_value,
            :children,
            :metadata

          def initialize(
            path:,
            key:,
            status:,
            old_value: nil,
            new_value: nil,
            children: [],
            metadata: {}
          )
            @path = path
            @key = key
            @status = status
            @old_value = old_value
            @new_value = new_value
            @children = children
            @metadata = metadata
          end

          def changed?
            status == :changed
          end

          def moved?
            status == :moved
          end

          def added?
            status == :added
          end

          def removed?
            status == :removed
          end

          def unchanged?
            status == :unchanged
          end

          def to_h
            {
              path: path,
              key: key,
              status: status,
              old_value: old_value,
              new_value: new_value,
              children: children.map(&:to_h),
              metadata: metadata
            }
          end
        end
      end
    end
  end
end