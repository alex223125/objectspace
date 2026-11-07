# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      class EntityVersionDiff
        Result = Struct.new(
          :root,
          :summary,
          :facts,
          keyword_init: true
        )


    def self.call(
      old_version:,
      new_version:,
      configuration: nil
    )
      new(
        old_version: old_version,
        new_version: new_version,
        configuration:
          configuration ||
            DiffIntelligence::Configuration.empty
      ).call
    end

    def initialize(
      old_version:,
      new_version:,
      configuration:
    )
      @old_version = old_version
      @new_version = new_version
      @configuration = configuration
    end

    def call
      root =
        DiffIntelligence::SemanticComparator
          .new(
            configuration: configuration
          )
          .call(
            snapshot(old_version),
            snapshot(new_version)
          )

      facts =
        DiffIntelligence::SemanticFactsCollector
          .call(root)

      Result.new(
        root: root,
        summary: build_summary(root),
        facts: facts
      )
    end

    private

    attr_reader :old_version, :new_version, :configuration

    def snapshot(version)
      if version.respond_to?(:snapshot)
        version.snapshot
      elsif version.respond_to?(:data)
        version.data
      elsif version.respond_to?(:content)
        version.content
      elsif version.respond_to?(:payload)
        version.payload
      else
        raise ArgumentError,
              "Unable to determine snapshot data for #{version.class.name}"
      end
    end

    def build_summary(root)
      counters = {
        added: 0,
        removed: 0,
        changed: 0,
        moved: 0,
        unchanged: 0,
        duplicate_identity: 0,
        missing_identity: 0,
        ambiguous_identity: 0
      }

      walk(root) do |node|
        status = node_value(node, :status)
        status = status.to_sym if status.respond_to?(:to_sym)

        counters[status] += 1 if counters.key?(status)

        metadata = node_value(node, :metadata)
        metadata = metadata.to_h if metadata.respond_to?(:to_h)
        metadata = {} unless metadata.is_a?(Hash)

        classification =
          metadata[:classification] ||
            metadata["classification"]

        case classification&.to_sym
        when :duplicate_identity
          counters[:duplicate_identity] += 1
        when :missing_identity
          counters[:missing_identity] += 1
        when :ambiguous_identity
          counters[:ambiguous_identity] += 1
        end
      end

      counters
    end

    def walk(node, &block)
      return if node.nil?

      yield node

      children =
        if node.respond_to?(:children)
          Array(node.children)
        else
          []
        end

      children.each do |child|
        walk(child, &block)
      end
    end

    def node_value(node, attribute)
      return unless node.respond_to?(attribute)

      node.public_send(attribute)
    end
  end
end

      end
    end
