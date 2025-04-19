module Services
  module Concerns
    module Technologies
      module Taggable

        def set_tags
          binding.pry
          technology.tag_list = parse_tags
        end

        def parse_tags
          if @params[:tag_list].present?
            binding.pry
            tags = JSON.parse(@params[:tag_list]).map{|h| h.values}
            binding.pry
            formatted_tags = cut_long_(tags)

            binding.pry
            tag_list = formatted_tags.join(",")

            binding.pry
            tag_list
          end
        end

        def cut_long_(tags)
          binding.pry
          formatted_tags_collection = []
          tags.flatten.each do |tag|
            # DOC: if it's more than 255 we have error
            # ActiveRecord::RecordInvalid: Validation failed: Tag: must exist, Tag: attribute is blank
            binding.pry
            if tag.length > 255
              binding.pry
              tag_parts = tag.chars.each_slice(255).map(&:join)

              binding.pry
              formatted_tags_collection.concat(tag_parts)
            else
              formatted_tags_collection << tag
            end
          end
          binding.pry
          formatted_tags_collection
        end
      end
    end
  end
end