module Memberable
  extend ActiveSupport::Concern

  included do

    private

    def redirect_to_member(technology)
      # DOC: If versioned technology placed inside SimpleClass or Framework we make a hyperlink
      # to place where its placed as in folder, not as a link
      binding.pry
      if container_members_present?(technology)
        binding.pry
        redirect_to_container_member(technology)
      elsif interface_members_present?(technology)
        binding.pry
        redirect_to_interface_member(technology)
      end
    end


    def container_members_present?(technology)
      binding.pry
      technology.whole_unit.container_members.present?
    end

    def interface_members_present?(technology)
      technology.whole_unit.interface_members.present?
    end

    def redirect_to_container_member(technology)
      binding.pry
      whole_unit = technology.whole_unit
      container_member = whole_unit.container_members.where(reference_type: ContainerMember::ReferenceTypes[:act_as_folder]).first
      class_container = container_member.class_container
      related_class_layer_entity = class_container.related_class_layer_entity

      binding.pry
      redirect_to container_member_path(ownername: related_class_layer_entity.ownerable.ownername, id: container_member.slug)
    end

    def redirect_to_interface_member(technology)
      binding.pry
      whole_unit = technology.whole_unit
      interface_member = whole_unit.interface_members.where(reference_type: InterfaceMembers::ReferenceTypes[:act_as_folder]).first
      interface_group = interface_member.interface_group
      related_class_layer_entity = interface_group.related_class_layer_entity

      binding.pry
      redirect_to interface_member_path(ownername: related_class_layer_entity.ownerable.ownername, id: interface_member.slug)
    end
  end
end