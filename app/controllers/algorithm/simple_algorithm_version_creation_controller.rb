class Algorithm::SimpleAlgorithmVersionCreationController < ApplicationController
  include Wicked::Wizard
  include Algorithm::Concerns::Subnodable
  include Placeable

  # Define the exact coherent 4-step sequence
  steps :algorithm_main, :algorithm_version_main, :introduction_content, :performing_content, :qr_code_content, :finishing_content

  before_action :authenticate_user!


  # before_action :set_algorithm
  before_action :set_algorithm, except: %i[new]
  # before_action :set_algorithm_version, remove: %i[new]
  before_action :set_algorithm_version, except: %i[new]

  before_action :set_target_place, only: %i[ new ]

  # This prevents 500 crashes on expired wizard tabs by safely nullifying the request session
  protect_from_forgery with: :null_session, only: [:update]

  # GET /algorithm/algorithms/:algorithm_id/simple_algorithm_version_creation/new
  def new
    @algorithm = Algorithms::Algorithm.new
    @algorithm_version = @algorithm.algorithm_versions.new
    binding.pry
    @algorithm.default_version = @algorithm_version

    @introduction_step = @algorithm_version.build_introduction_step
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

    ## From Algorithm.new service
    @algorithm.ownerable = current_user
    @algorithm.creator = current_user

    @target_place = set_target_place
    set_place

    binding.pry

    if params[:functional_type].present?
      @functional_type = Algorithms::FunctionalTypes[params[:functional_type]]
    else
      @functional_type = Algorithms::FunctionalTypes[:regular]
    end
    @algorithm.functional_type = @functional_type
    ###

    # do in transaction block
    @algorithm.save(validate: false)
    @algorithm_version.save(validate: false)
    @algorithm.default_version_id = @algorithm_version.id
    @algorithm.save(validate: false)
    success = true

    binding.pry
    if success
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


  def set_place
    binding.pry
    if @target_place.class == Folder
      @algorithm.folder = @target_place
    elsif @target_place.class == Repository
      @algorithm.repository = @target_place
    elsif @target_place.class == ::SimpleClasses::ClassContainer
      binding.pry
      container_member = create_container_member
      binding.pry
      @algorithm.class_containers << container_member
    elsif @target_place.class == ::SimpleClasses::InterfaceGroup
      binding.pry
      interface_member = create_interface_member
      binding.pry
      @algorithm.interface_members << interface_member
    elsif @target_place.class == ::Frameworks::FrameworkInterface
      @algorithm.framework_interface = @target_place
    elsif @target_place.class == ::SimpleClasses::SimpleClassInterface
      @algorithm.simple_class_interface = @target_place
    end
  end

  def create_algorithm_version_algorithm_tree
    binding.pry
    algorithm_version = @algorithm.default_version
    binding.pry
    service = Services::Algorithms::Navigation::AlgorithmTrees::Create.new(algorithm_version)

    binding.pry
    service.call
    binding.pry
    if service.algorithm_tree.errors.present?
      binding.pry
      @algorithm_tree = service.algorithm_tree
      raise ActiveRecord::RecordInvalid.new(service.algorithm_tree)
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
    when :qr_code_content
      binding.pry
    when :finishing_content
      binding.pry
      # Summary review logic
    end
    Rails.logger.debug("WIZARD ERROR: #{@algorithm_version.errors.full_messages}")
    Rails.logger.debug("WIZARD ERROR: #{@algorithm.errors.full_messages}")

    # Calculate the highest step the user has successfully reached based on data presence
    @max_accessible_step = determine_maximum_reached_step

    render_wizard
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
                     when :qr_code_content then algorithm_print_params # Maps parameters securely
                     when :finishing_content then params.permit(:publish)
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


      # steps :algorithm_main, :algorithm_version_main, :introduction_content, :performing_content, :finishing_content


      case setup_step_from(step)

      when :algorithm_main

        binding.pry
        # Assign incoming form values to your parent model
        @algorithm.assign_attributes(current_params)
        @algorithm_version.wizard_creation_stage_id = AlgorithmVersions::WizardCreationStagesTypes[:record_initiated]

        # 1. FORCE VALIDATION IN MEMORY: This populates @algorithm.errors for your ERB view failure blocks
        # @algorithm.valid?

        # 2. FORCE SAVE DRAFT: Commits parameters to DB bypassing validation rules
        save_success = @algorithm.save(validate: false)

      when :algorithm_version_main
        # if of algorithm_version exists
        # [5] pry(#<Algorithm::SimpleAlgorithmVersionCreationController>)> current_params[:algorithm_versions_attributes].values
        # => [#<ActionController::Parameters {"id"=>"82", "title"=>"agsagsag", "interactivity_type_id"=>"2", "description"=>"<p>gaagsags</p>", "solves_the_problem"=>"<p>sgaasgag</p>", "sources"=>"<p>gsaagas</p>", "additional_information"=>"<p>gsaaags</p>"} permitted: true>]
        # params = current_params[:algorithm_versions_attributes]
        algrithm_version_params = current_params[:algorithm_versions_attributes]["0"]

        binding.pry
        @algorithm_version.assign_attributes(algrithm_version_params)

        binding.pry
        @algorithm_version.wizard_creation_stage_id = AlgorithmVersions::WizardCreationStagesTypes[:main_created]
        # Populate the errors array for version objects
        # @algorithm_version.valid?

        save_success = @algorithm_version.save(validate: false)

      when :introduction_content
        binding.pry
        introduction_step = @algorithm_version.introduction_step
        introduction_step.assign_attributes(current_params)
        @algorithm_version.wizard_creation_stage_id = AlgorithmVersions::WizardCreationStagesTypes[:introduction_created]
        # Populate the errors array for version objects
        # @algorithm_version.valid?

        save_success = @algorithm_version.save(validate: false)

      when :performing_content
        @algorithm_version.wizard_creation_stage_id = AlgorithmVersions::WizardCreationStagesTypes[:performing_content_created]
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
        ################################################################################################################

        binding.pry
        create_algorithm_version_algorithm_tree
        # save_success = @algorithm_version.save(validate: false)
        save_success = service.errors.blank?

      when :qr_code_content
        binding.pry
        @algorithm_version.wizard_creation_stage_id = AlgorithmVersions::WizardCreationStagesTypes[:qr_code_content_created]

        # 2. Extract nested strong parameters from the parent form data wrapper
        @algorithm.assign_attributes(algorithm_print_params)

        binding.pry
        save_success = false
        save_success = true if @algorithm_version.save(validate: false)
        save_success = true if @algorithm.update(current_params)

        # 3. Save the record and automatically advance to the next wizard step (finishing_content)
        # render_wizard calls @algorithm.save behind the scenes and handles the redirection
        # render_wizard(@algorithm)


        # if save_success
        #   # Redirect back to the correct wizard stage with a 303 status
        #   redirect_to simple_algorithm_version_creation_path(algorithm_id: @algorithm.id,
        #                                                      wizard_id: @step.to_s,
        #                                                      algorithm_version_id: @algorithm_version.slug),
        #               status: :see_other,
        #               notice: "QR Code saved successfully!"
        # else
        #   render :edit, status: :unprocessable_entity
        # end

        binding.pry
        # 1. Process text parameter attributes across the parent algorithm nesting layers
        if save_success

          binding.pry
          # Reload instance definitions to read the fresh attributes written via nested update
          @algorithm_version.reload

          # 2. Intercept and handle binary file generation formatting downloads instantly
          if params[:export_format] == "pdf" && @algorithm_version.printable_pdf_manifest.attached?
            send_data @algorithm_version.printable_pdf_manifest.download,
                      filename: "blueprint_passport_#{@algorithm_version.id}.pdf",
                      type: "application/pdf",
                      disposition: "attachment" and return
          elsif params[:export_format] == "svg" && @algorithm_version.qr_vector_blob.attached?
            send_data @algorithm_version.qr_vector_blob.download,
                      filename: "vector_blueprint_#{@algorithm_version.id}.svg",
                      type: "image/svg+xml",
                      disposition: "attachment" and return
          end
        else
          save_success = false
        end
      when :finishing_content
        binding.pry
        @algorithm_version.wizard_creation_stage_id = AlgorithmVersions::WizardCreationStagesTypes[:finishing_content_created]
        save_success = @algorithm_version.save(validate: false)
      else
        binding.pry
        @algorithm_version.wizard_creation_stage_id = AlgorithmVersions::WizardCreationStagesTypes[:complete_record_created]
        save_success = @algorithm_version.save(validate: false)
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
  end

  private

  # FIX: Permit the print fields from the :algorithm_version scope parameter key wrapper
  def algorithm_print_params
    params.require(:algorithms_algorithm).permit(
      algorithm_versions_attributes: [:id, :print_title, :short_print_description]
    )
  end


  def determine_maximum_reached_step
    # If the version is published or complete, everything is open
    # return :finishing_content if @algorithm_version.searchable? || @algorithm.wizard_creation_stage_id == Algorithms::WizardCreationStagesTypes[:published]

    # Check if they have reached the performing step (nested control structures exist)
    # binding.pry

    binding.pry
    if AlgorithmVersions::WizardCreationStagesTypes[@algorithm_version.wizard_creation_stage_id] == "finishing_content_created"

      binding.pry
      return :finishing_content
    elsif AlgorithmVersions::WizardCreationStagesTypes[@algorithm_version.wizard_creation_stage_id] == "qr_code_content_created"
      binding.pry
      return :qr_code_content
    elsif AlgorithmVersions::WizardCreationStagesTypes[@algorithm_version.wizard_creation_stage_id] == "performing_content_created"
      return :performing_content
    elsif AlgorithmVersions::WizardCreationStagesTypes[@algorithm_version.wizard_creation_stage_id] == "introduction_created"
      return :introduction_content
    elsif AlgorithmVersions::WizardCreationStagesTypes[@algorithm_version.wizard_creation_stage_id] == "main_created"
      return :algorithm_version_main
    elsif AlgorithmVersions::WizardCreationStagesTypes[@algorithm_version.wizard_creation_stage_id] == "complete_record_created"
      return :algorithm_main
    end
  end


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
    # 1. Prioritize the explicit ID token key first
    algorithm_version_id = params[:algorithm_version_id]

    # 2. Fall back to params[:id] ONLY if it represents a database record and NOT a step name
    if algorithm_version_id.blank? && params[:id].present?
      unless steps.map(&:to_s).include?(params[:id].to_s)
        algorithm_version_id = params[:id]
      end
    end

    # 3. Secure execution extraction
    if algorithm_version_id.present?
      @algorithm_version = @algorithm.algorithm_versions.friendly.find(algorithm_version_id)
    else
      # Fallback to the latest active version draft under this parent container
      @algorithm_version = @algorithm.algorithm_versions.last
    end
  rescue ActiveRecord::RecordNotFound
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
    params.require(:algorithms_algorithm).permit(algorithm_versions_attributes: [:id, :title, :interactivity_type_id,
                                                                                 :description, :solves_the_problem,
                                                                                 :sources, :additional_information,
                                                                                 :cover_image] )
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

end