class ApplicationController < ActionController::Base

  include Pagy::Backend

  include RecursiveParametersBuilder

  before_action :configure_active_storage, if: -> { Rails.env.development? }

  def configure_active_storage
    # ActiveStorage::Current.host = request.base_url
    # ActiveStorage::Current.url_options = "http://127.0.0.1:3000/"
    ActiveStorage::Current.url_options = request.base_url
  end

  private

  # TODO: move it to concern for simple_classes
  # for container and interface groups
  def class_containers_attributes
    {        class_containers_attributes: [:id, :position, :title, :description, :_destroy,
                                           containers_attributes: [:id, :position, :title, :description, :_destroy, recursive_nested_containers_attr,
                                           container_members_attributes: [:id, :memberable_type, :memberable_id,
                                                                          :_destroy]]
    ]}
  end

  def interface_groups_attributes
    {interface_groups_attributes: [:id, :position, :title, :description, :_destroy,
                                   groups_attributes: [:id, :position, :title, :description, :_destroy, recursive_nested_groups_attr,
                                   interface_members_attributes: [:id, :memberable_type, :memberable_id, :position,
                                                                  :_destroy]]
    ]}
  end

  def recursive_nested_containers_attr
    build_recursive_params(
      recursive_key: 'containers_attributes',
      parameters: params,
      permitted_attributes: [:id, :position, :title, :description, :_destroy]
    )
  end

  def recursive_nested_groups_attr
    build_recursive_params(
      recursive_key: 'groups_attributes',
      parameters: params,
      permitted_attributes: [:id, :position, :title, :description, :_destroy]
    )
  end


end
