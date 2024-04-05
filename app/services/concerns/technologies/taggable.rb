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
            JSON.parse(@params[:tag_list]).map{|h| h.values}.join(",")
          end
        end
      end
    end
  end
end