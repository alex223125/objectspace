module Sourceable
  extend ActiveSupport::Concern

  # DOC: Each technology can be located in one of these places
  def source_location
    if self.folder.present?
      self.folder
    elsif self.repository.present?
      self.repository
    elsif self.container_member_as_source_location.present?
      self.container_member_as_source_location
    elsif self.interface_member_as_source_location.present?
      self.interface_member_as_source_location
    elsif self.framework_interface.present?
      self.framework_interface
    end
  end

  def container_member_as_source_location
    self.container_members.where(reference_type: ContainerMember::ReferenceTypes[:act_as_folder]).first
  end

  def interface_member_as_source_location
    self.interface_members.where(reference_type: ContainerMember::ReferenceTypes[:act_as_folder]).first
  end


end