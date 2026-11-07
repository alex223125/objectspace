# frozen_string_literal: true

module Ecosystems
  module LoadSources
    module Entity
      module DiffIntelligence
        class InlineStringDiff
          Segment =
            Struct.new(
              :type,
              :text,
              keyword_init: true
            )

          Result =
            Struct.new(
              :old_segments,
              :new_segments,
              keyword_init: true
            )

          def self.call(old_value, new_value)
            new.call(old_value, new_value)
          end

          def call(old_value, new_value)
            old_text = old_value.to_s
            new_text = new_value.to_s

            return unchanged(old_text) if old_text == new_text

            prefix_length =
              common_prefix_length(
                old_text,
                new_text
              )

            suffix_length =
              common_suffix_length(
                old_text,
                new_text,
                prefix_length
              )

            old_middle_end =
              old_text.length - suffix_length

            new_middle_end =
              new_text.length - suffix_length

            prefix =
              old_text[0, prefix_length]

            old_middle =
              old_text[
                prefix_length,
                old_middle_end - prefix_length
              ]

            new_middle =
              new_text[
                prefix_length,
                new_middle_end - prefix_length
              ]

            suffix =
              suffix_length.zero? ?
                "" :
                old_text[-suffix_length, suffix_length]

            Result.new(
              old_segments:
                build_segments(
                  prefix: prefix,
                  middle: old_middle,
                  suffix: suffix,
                  middle_type: :removed
                ),
              new_segments:
                build_segments(
                  prefix: prefix,
                  middle: new_middle,
                  suffix: suffix,
                  middle_type: :added
                )
            )
          end

          private

          def unchanged(text)
            segment =
              Segment.new(
                type: :unchanged,
                text: text
              )

            Result.new(
              old_segments: [segment],
              new_segments: [segment]
            )
          end

          def common_prefix_length(left, right)
            max = [left.length, right.length].min
            index = 0

            while index < max &&
              left.getbyte(index) == right.getbyte(index)
              index += 1
            end

            index
          end

          def common_suffix_length(left, right, prefix_length)
            max =
              [
                left.length - prefix_length,
                right.length - prefix_length
              ].min

            index = 0

            while index < max &&
              left.getbyte(left.length - 1 - index) ==
                right.getbyte(right.length - 1 - index)
              index += 1
            end

            index
          end

          def build_segments(prefix:, middle:, suffix:, middle_type:)
            segments = []

            unless prefix.empty?
              segments << Segment.new(
                type: :unchanged,
                text: prefix
              )
            end

            unless middle.empty?
              segments << Segment.new(
                type: middle_type,
                text: middle
              )
            end

            unless suffix.empty?
              segments << Segment.new(
                type: :unchanged,
                text: suffix
              )
            end

            segments
          end
        end
      end
    end
  end
end