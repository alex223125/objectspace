module Services
  module Concerns
    module Technologies
      module Memberable

        def create_interface_member
          binding.pry
          technology_title = technology.title

          binding.pry
          interface_member = @target_place.interface_members.new(title: technology_title)
          # DOC: When we creating article (or another technology) using ui interface of SimpleClass we by default putting
          # article inside interface group as in folder
          binding.pry
          interface_member.reference_type = InterfaceMembers::ReferenceTypes[:act_as_folder]

          binding.pry
          interface_member
        end

        def create_container_member
          binding.pry
          technology_title = technology.title
          binding.pry
          container_member = @target_place.container_members.new(title: technology_title)
          # DOC: When we creating article (or another technology) using ui interface of SimpleClass we by default putting
          # article inside ClassContainer as in folder
          binding.pry
          container_member.reference_type = ContainerMember::ReferenceTypes[:act_as_folder]
          container_member
        end

        def create_framework_folder_member
          binding.pry
          technology_title = technology.title
          framework_folder_member = @target_place.framework_members.new(title: technology_title)
          framework_folder_member.reference_type = FrameworkMembers::ReferenceTypes[:act_as_folder]

          binding.pry
          framework_folder_member
        end
      end
    end
  end
end

