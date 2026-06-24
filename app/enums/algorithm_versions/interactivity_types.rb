module AlgorithmVersions
  class InteractivityTypes < ActiveEnum::Base
    value :id => 1, :name => :simple_static_algorithm
    value :id => 2, :name => :simple_interactive_algorithm
    value :id => 3, :name => :some_type_three

    def self.description(id)
      case id.to_i
      when 1 then "Processes logic serverside. Best for standard linear calculation workflows."
      when 2 then "Renders configuration rules on a single viewport canvas simultaneously."
      when 3 then "Employs progressive layout layers using contextual wizard animations."
      else "No description available."
      end
    end

    def self.name_value_by_name(simple_static_algorithm)
      case simple_static_algorithm
      when :simple_static_algorithm then "simple_static_algorithm"
      when :simple_interactive_algorithm then "simple_interactive_algorithm"
      when :some_type_three then "some_type_three"
      else "No description available."
      end
    end
  end
end