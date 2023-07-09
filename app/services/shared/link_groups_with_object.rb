module Services
  module Shared
    class LinkGroupsWithObject

      def initialize(object, root_object_association, child_objects_associations)
        @object = object
        @root_object_association = root_object_association
        @child_objects_associations = child_objects_associations
      end

      def call
        binding.pry
        link_object_with_all_groups
      end

      private

      # why: container.root.simple_class.id not faster the container.simple_class_id
      def link_object_with_all_groups
        binding.pry
        # there always will be not more than 1 instance
        root_group = @object.public_send(@root_object_association).first
        return if root_group.blank?

        binding.pry
        root_group.public_send(@child_objects_associations).each do |group|
          recursively_link_object_with_(group)
        end
      end

      def recursively_link_object_with_(group)
        if @object.class == "SimpleClasses::SimpleClass"
          group.simple_class = @object
        elsif @object.class == "Frameworks::Framework"
          group.framework = @object
        end

        if group.public_send(@child_objects_associations).any?
          group.public_send(@child_objects_associations).each do |next_group|
            recursively_link_object_with_(next_group)
          end
        end
      end

    end
  end
end
