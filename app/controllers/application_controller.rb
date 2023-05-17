class ApplicationController < ActionController::Base

  include Pagy::Backend

  include RecursiveParametersBuilder

  private

  # for container and interface groups
  def class_containers_attributes
    {        class_containers_attributes: [:title, :description, :_destroy,
                                           containers_attributes: [:title, :description, :_destroy, recursive_nested_containers_attr],
                                           container_members_attributes: [:memberable_type, :memberable_id,
                                                                          :_destroy]
    ]}
  end

  def interface_groups_attributes
    {interface_groups_attributes: [:position, :title, :description,
                                   :_destroy,
                                   groups_attributes: [:title, :description, :_destroy, recursive_nested_groups_attr],
                                   interface_members_attributes: [:memberable_type, :memberable_id,
                                                                  :_destroy]
    ]}
  end

  def recursive_nested_containers_attr
    build_recursive_params(
      recursive_key: 'containers_attributes',
      parameters: params,
      permitted_attributes: [:title, :description, :_destroy]
    )
  end

  def recursive_nested_groups_attr
    build_recursive_params(
      recursive_key: 'groups_attributes',
      parameters: params,
      permitted_attributes: [:title, :description, :_destroy]
    )
  end


end
