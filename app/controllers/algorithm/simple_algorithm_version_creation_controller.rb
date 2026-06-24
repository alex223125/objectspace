class Algorithm::SimpleAlgorithmVersionCreationController < ApplicationController
  include Wicked::Wizard
  include Algorithm::Concerns::Subnodable

  # Define the exact coherent 4-step sequence
  steps :algorithm_main, :algorithm_version_main, :introduction_content, :performing_content, :finishing_content

  before_action :authenticate_user!
  # before_action :set_algorithm
  before_action :set_algorithm, except: %i[new]
  # before_action :set_algorithm_version, remove: %i[new]
  before_action :set_algorithm_version, except: %i[new]

  # GET /algorithm/algorithms/:algorithm_id/simple_algorithm_version_creation/new
  def new
    @algorithm = Algorithms::Algorithm.new
    @algorithm_version = @algorithm.algorithm_versions.new

    # # 1. Initialize a baseline version draft
    # @algorithm_version = @algorithm.algorithm_versions.new(
    #   title: "Draft Version #{Time.current.strftime('%Y%m%d%H%M')}",
    #   display_type: 1 # Default configuration
    # )

    # 2. Build initial blank nested associations
    # @algorithm_version.build_introduction_step
    # @algorithm_version.control_structures.build

    @introduction_step = @algorithm_version.build_introduction_step
    # @control_structure = @algorithm_version.control_structures.new
    # algorithm_default_control_structure = ControlStructures::FunctionalTypes[:following]
    # @default_algorithm_structure = @algorithm_version.control_structures.new(control_structure_functional_type: algorithm_default_control_structure)
    @default_algorithm_structure = @algorithm_version.control_structures.new

    binding.pry
    if params[:functional_type].present?
      @functional_type = Algorithms::FunctionalTypes[params[:functional_type]]
    else
      @functional_type = Algorithms::FunctionalTypes[:regular]
    end

    binding.pry
    if @target_framework_interface.present?
      binding.pry
      @framework = @target_framework_interface.framework
    elsif @target_simple_class_interface.present?
      @simple_class = @target_simple_class_interface.simple_class
    end


    # 3. Save draft without enforcing validations yet (validate: false)

    binding.pry
    # prepare draft version which is ready for next steps of creation of algorithm_version
    @algorithm_version.wizard_creation_stage_id = AlgorithmVersions::WizardCreationStagesTypes[:draft_created]
    # set default position for base control structure of algorithm
    @algorithm_version.control_structures.first.position = Algorithms::AlgorithmVersion::BASE_CONTROL_STRUCTURE_DEFAULT_POSITION

    ### Algorithm draft creation
    # prepare draft version which is ready for next steps of creation of algorithm_version
    @algorithm.wizard_creation_stage_id = Algorithms::WizardCreationStagesTypes[:draft_created]
    @algorithm.ownerable = current_user
    binding.pry

    if params[:functional_type].present?
      @functional_type = Algorithms::FunctionalTypes[params[:functional_type]]
    else
      @functional_type = Algorithms::FunctionalTypes[:regular]
    end
    @algorithm.functional_type = @functional_type
    ### 

    binding.pry
    if @algorithm.save(validate: false)
      binding.pry

      # 4. Redirect straight to step 1 passing the new record ID
      # redirect_to algorithm_algorithm_simple_algorithm_version_creation_path(
      redirect_to simple_algorithm_version_creation_path(
                    algorithm_id: @algorithm.id,
                    wizard_id: :algorithm_main,
                    algorithm_version_id: @algorithm_version.slug
                  )
    else
      binding.pry
      redirect_to algorithm_algorithms_path, alert: "Failed to initialize creation wizard."
    end
  end

  # GET /algorithm/algorithms/:algorithm_id/simple_algorithm_version_creation/:id
  def show
    case setup_step_from(step)
    when :algorithm_main
      binding.pry
      # Metadata defaults
    when :algorithm_version_main
      # Metadata defaults
    when :introduction_content
      binding.pry
      @introduction_step = @algorithm_version.introduction_step || @algorithm_version.build_introduction_step
    when :performing_content
      binding.pry
      @control_structure = @algorithm_version.control_structures.first || @algorithm_version.control_structures.build
    when :finishing_content
      binding.pry
      # Summary review logic
    end
    Rails.logger.debug("WIZARD ERROR: #{@algorithm_version.errors.full_messages}")
    Rails.logger.debug("WIZARD ERROR: #{@algorithm.errors.full_messages}")

    # respond_to do |format|
    #   format.html { render_wizard }
    #   format.turbo_stream { render_wizard }
    # end

    # respond_to do |format|
    #   format.html { render_wizard }
    #   format.turbo_stream do
    #     render template: "algorithm/simple_algorithm_version_creation/#{step}",
    #            formats: [:html],
    #            layout: true
    #   end
    # end


    render_wizard
    # redirect_to next_wizard_path(:introduction_content, algorithm_id: @algorithm.id, algorithm_version_id: @algorithm_version.slug)

    # # binding.pry
    # # render_wizard
    # if setup_step_from(step) == :introduction_content
    #   # binding.pry
    #   # redirect_to wizard_path(
    #   #               algorithm_id: @algorithm.id,
    #   #               wizard_id: step.to_s,
    #   #               algorithm_version_id: @algorithm_version.slug
    #   #             )
    #   # render_wizard nil, template: "algorithm/simple_algorithm_version_creation/introduction_content"
    #   # redirect_to next_wizard_path
    #   # redirect_to wizard_path(algorithm_id: @algorithm.id, algorithm_version_id: @algorithm_version.slug)
    #   redirect_to wizard_path(:introduction_content, algorithm_id: @algorithm.id, algorithm_version_id: @algorithm_version.slug)
    #
    # else
    #   binding.pry
    #   Rails.logger.debug("WIZARD ERROR: #{@algorithm_version.errors.full_messages}")
    #   Rails.logger.debug("WIZARD ERROR: #{@algorithm.errors.full_messages}")
    #   render_wizard
    # end
  end

  # PUT /algorithm/algorithms/:algorithm_id/simple_algorithm_version_creation/:id
  def update
    binding.pry
    # Select parameters scope dynamically based on the current step
    current_params = case setup_step_from(step)
                     when :algorithm_main then algorithm_base_params
                     when :algorithm_version_main then algorithm_version_main_params
                     when :introduction_content then algorithm_version_intro_params
                     # paramsp prepared at the bottom of method
                     # when :performing_content then algorithm_version_steps_params
                     when :finishing_content then params.permit(:publish) # final marker
                     end


    binding.pry
    # Handle update transaction processing logic
    if setup_step_from(step) == :finishing_content

      binding.pry
      # Finalize and activate the complete validated record parameters
      if @algorithm_version.update(searchable: true)

        binding.pry
        redirect_to algorithm_version_path(ownername: @algorithm_version.algorithm.ownerable.ownername, id: @algorithm_version.slug),
                    notice: "Algorithm Quest successfully initialized!"
      else

        binding.pry
        render_wizard
      end
    else
      # Core Step 1, 2, and 3 transaction routing
      save_success = false
      binding.pry

      case setup_step_from(step)
      when :algorithm_main

        binding.pry
        # Assign incoming form values to your parent model
        @algorithm.assign_attributes(current_params)

        # 1. FORCE VALIDATION IN MEMORY: This populates @algorithm.errors for your ERB view failure blocks
        # @algorithm.valid?

        # 2. FORCE SAVE DRAFT: Commits parameters to DB bypassing validation rules
        save_success = @algorithm.save(validate: false)

      when :introduction_content

        binding.pry
        introduction_step = @algorithm_version.introduction_step
        introduction_step.assign_attributes(current_params)
        # Populate the errors array for version objects
        # @algorithm_version.valid?

        save_success = @algorithm_version.save(validate: false)

      when :algorithm_version_main
        binding.pry
        # if of algorithm_version exists
        # [5] pry(#<Algorithm::SimpleAlgorithmVersionCreationController>)> current_params[:algorithm_versions_attributes].values
        # => [#<ActionController::Parameters {"id"=>"82", "title"=>"agsagsag", "interactivity_type_id"=>"2", "description"=>"<p>gaagsags</p>", "solves_the_problem"=>"<p>sgaasgag</p>", "sources"=>"<p>gsaagas</p>", "additional_information"=>"<p>gsaaags</p>"} permitted: true>]
        # params = current_params[:algorithm_versions_attributes]
        algrithm_version_params = current_params[:algorithm_versions_attributes]["0"]
        @algorithm_version.assign_attributes(algrithm_version_params)

        # Populate the errors array for version objects
        # @algorithm_version.valid?

        save_success = @algorithm_version.save(validate: false)

      when :performing_content

        # # DOC: 1.prepare parames
        # action_type = :algorithm_version_create
        # service = Services::Algorithms::Shared::Params::Create.new(params, action_type)
        # new_params = service.call
        # @structured_params = ActionController::Parameters.new(new_params)
        # params = algorithm_version_params


        ################################################################################################################
        binding.pry
        action_type = :simple_algorithm_version_creation
        service = Services::Algorithms::Shared::Params::Create.new(params, action_type)
        binding.pry
        new_params = service.call
        binding.pry
        @structured_params = ActionController::Parameters.new(new_params)


        # 2.update record
        binding.pry
        algorithm_version_params = algorithm_version_steps_params
        service = Services::Algorithms::AlgorithmVersions::Update.new(@algorithm_version, algorithm_version_params)
        service.call
        #################################################################################################################




        # binding.pry
        # @algorithm_version.assign_attributes(params)

        # Populate the errors array for version objects
        # @algorithm_version.valid?

        # save_success = @algorithm_version.save(validate: false)
        save_success = service.errors.blank?
      end

      # 3. CONTROLLING WIZARD NAVIGATION BASED ON ERRORS
      if save_success

        binding.pry
        # Pick the active object depending on the step you are on
        current_entity = (setup_step_from(step) == :algorithm_main) ? @algorithm : @algorithm_version

        # If manually triggered validation errors exist, DO NOT advance steps; stay on the page to show them
        if current_entity.errors.present?
          binding.pry
          render_wizard
        else

          binding.pry
          # If no errors exist, safely move forward on the map
          redirect_to next_wizard_path(
                        algorithm_id: @algorithm.id,
                        wizard_id: next_step(step).to_s,
                        algorithm_version_id: @algorithm_version.slug
                      )
        end
      else
        binding.pry
        render_wizard
      end
    end


    #   binding.pry
    #
    #    case setup_step_from(step)
    #    when :main
    #      @algorithm.assign_attributes(algorithm_base_params)
    #     # then algorithm_base_params
    #    when :introduction
    #      # 1. Load the incoming parameter hash elements straight into memory attributes
    #      @algorithm_version.assign_attributes(algorithm_version_intro_params)
    #     # then algorithm_version_intro_params
    #    when :performing_content
    #      # 1. Load the incoming parameter hash elements straight into memory attributes
    #      @algorithm_version.assign_attributes(algorithm_version_steps_params)
    #     # then algorithm_version_steps_params
    #    when :finishing_content
    #     # then params.permit(:publish) # final marker
    #    end
    #
    #
    #   # 2. FORCEFULLY SAVE THE RECORD WHILE COMPLETELY BYPASSING THE VALIDATION RULES
    #   if @algorithm_version.save(validate: false)
    #
    #     binding.pry
    #     # Verify custom base backend array errors if moving past step 3 (content step)
    #     if setup_step_from(step) == :performing_content && @algorithm_version.errors[:base].present?
    #       @control_structure = @algorithm_version.control_structures.first
    #       render_wizard
    #     else
    #       redirect_to next_wizard_path
    #     end
    #   else
    #
    #     binding.pry
    #     render_wizard
    #   end
    # end
  end

  private


  # BULLETPROOF WICKED PARAMETER DEC0UPLE OVERRIDE:
  # Intercepts the routing parameters chain and feeds Wicked the :wizard_id instead of :id
  def setup_step_from(the_step)
    # Extract the step name safely out of your custom routing parameter key slot
    binding.pry
    current_wizard_step = params[:wizard_id] || the_step

    # Scan the active steps collection to verify a clean match array exists
    binding.pry
    valid_steps = steps
    resolved_step = valid_steps.detect { |stp| stp.to_s == current_wizard_step.to_s }

    # Fallback onto the internal state tracker step if parameters resolve to nil
    binding.pry
    resolved_step || step
  end

  # We can not drop eplicitly params into render_wizard method, so
  # in case if we used setup_step_from(the_step) method when we use
  # this override which looks for already defined wizard_id and goes from it
  #
  # CRITICAL WICKED STATE RECOVERY OVERRIDE:
  # This completely replaces setup_step_from and forces Wicked's core internal attribute reader
  # to prioritize your custom :wizard_id token over standard params[:id] strings
  def step
    if params[:wizard_id].present?
      valid_steps = steps
      resolved = valid_steps.detect { |stp| stp.to_s == params[:wizard_id].to_s }
      return resolved if resolved.present?
    end

    super
  end

  def set_algorithm
    binding.pry
    @algorithm = Algorithms::Algorithm.find(params[:algorithm_id])
  end

  def set_algorithm_version
    binding.pry
    # Track either passed version token parameter mapping or fallback to step route id parameters
    algorithm_version_id = params[:algorithm_version_id] || params[:id]

    binding.pry
    @algorithm_version = @algorithm.algorithm_versions.friendly.find(algorithm_version_id)
  rescue ActiveRecord::RecordNotFound

    binding.pry
    redirect_to root_path, alert: "Target draft not located."
  end

  # Step parameter isolation scopes
  def algorithm_base_params
    binding.pry
    params.require(:algorithms_algorithm).permit(:title, :source_page_description, :tag_list, :functional_type)
  end

  def algorithm_version_intro_params
    binding.pry
    # params.require(:algorithms_introduction_step).permit(
    #   introduction_step_attributes: [:id, :title, :content]
    # )
    params.require(:algorithms_introduction_step).permit(:id, :title, :content)
  end

  def algorithm_version_main_params
    params.require(:algorithms_algorithm).permit(algorithm_versions_attributes: [:id, :title, :interactivity_type_id, :description, :solves_the_problem,
                                                                                         :sources, :additional_information] )
  end



  def algorithm_version_steps_params
    binding.pry
    @structured_params.require(:algorithms_algorithm).permit(algorithm_versions_attributes: [

      control_structures_attributes: [

      :id,
      :position,
      :control_structure_functional_type,
      :_destroy,

      subnodes_attributes: [
        :technologiable_type,
        :technologiable_id,

        :id,

        :position,
        :type,
        :title,
        :instruction,
        :step_finish_check,
        :solves_the_problem,
        :sources,
        :additional_information,

        :step_functional_type,
        :control_structure_functional_type,
        :note,
        :description,

        :_destroy,
        recursive_nested_substeps_attr,
        conditions_attributes: [:id, :title,
                                :instruction, :_destroy,],
        attachments_attributes: [:id, :attachable_id,
                                 :attachable_type, :_destroy]]
      ]
    ])
  end



  # def algorithm_version_steps_params
  #   binding.pry
  #   params.require(:algorithms_algorithm_version).permit(
  #     control_structures_attributes: [
  #       :id, :position, :control_structure_functional_type, :_destroy,
  #       subnodes_attributes: [
  #         :id, :technologiable_type, :technologiable_id, :position,
  #         :type, :title, :instruction, :step_finish_check, :solves_the_problem, :_destroy
  #       ]
  #     ]
  #   )
  # end
end