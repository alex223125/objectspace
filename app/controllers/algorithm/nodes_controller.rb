# DOC: we use this controller during creation of algorithm
class Algorithm::NodesController < ApplicationController

  def template
    binding.pry
    if params[:type] == "regular_step"
      path = "algorithm/shared/partials/steps/regular_substep_dynamic_form"
      form_object = Algorithms::Nodes::Step.new
    elsif params[:type] == "wrapper_step"
      path = "algorithm/shared/partials/steps/wrapper_substep_dynamic_form"
      form_object = Algorithms::Nodes::Step.new
    elsif params[:type] == "container_step"
      path = "algorithm/shared/partials/steps/continer_substep_dynamic_form"
      form_object = Algorithms::Nodes::Step.new

    elsif params[:type] == "single_alternative_control_structure"
      path = "algorithm/shared/partials/control_structures/single_alternative_cs_dynamic_form"
      form_object = Algorithms::Nodes::ControlStructure.new
    end

    form = SimpleForm::FormBuilder.new(
      "dynamic_node_#{Time.now.strftime("%I%M%S")}", # the scope for the inputs
      form_object,        # object wrapped by the form builder
      view_context,  # the template where the form builder can call the tag helpers on
      {}             # options
    )

    # if params[:type] == "regular_step"
    #   # path = "algorithm/shared/partials/substeps/regular_substep_fields"
    #   path = "algorithm/shared/partials/substeps/regular_substep_dynamic_form"
    #   # path = "algorithm/shared/partials/preview/algorithm/main_page"
    # elsif params[:type] == "wrapper_step"
    #   path = "algorithm/shared/partials/substeps/wrapper_substep_fields"
    # end

    template = render_to_string(
      partial: path,
      layout: false,
      locals: { form: form },
      formats: [:html]
    )

    # format.json {
    #   render json: { substep_template: render_to_string(partial: path, formats: [:html])}
    # }

    respond_to do |format|
      format.json {
        render json: { substep_template: template }
      }
    end
  end
end
