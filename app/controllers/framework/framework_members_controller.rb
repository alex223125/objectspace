class Framework::FrameworkMembersController < ApplicationController
  include TechBreadcrumbable
  # include Commentable

  before_action :set_framework_member, only: %i[ show edit update destroy ]
  before_action :set_framework, only: %i[ new_members ]
  before_action :set_framework_folder, only: %i[ create_members ]

  # GET /container_members or /container_members.json
  # def index
  #   @container_members = ContainerMember.all
  # end

  # GET /container_members/1 or /container_members/1.json
  def show
    binding.pry
    technology_breadcrumbs(@framework_member)
  end

  def framework_folder_members_list
    set_framework_folder
    framework_members = @framework_folder.framework_members
    members_collection = framework_members.map{|a| {id: a.framework_memberable_id, class: a.framework_memberable_type} }
    render json: members_collection
  end

  # GET /container_members/new
  def new
    @framework_member = Framework::FrameworkMember.new
  end

  def new_members
    binding.pry
    @target_framework_folder = Frameworks::FrameworkFolder.find_by(uuid: params[:target_framework_folder])
  end


  # GET /container_members/1/edit
  # def edit
  # end

  # POST /container_members or /container_members.json
  # def create
  #   @container_member = ContainerMember.new(container_member_params)
  #
  #   respond_to do |format|
  #     if @container_member.save
  #       format.html { redirect_to container_member_url(@container_member), notice: "Container member was successfully created." }
  #       format.json { render :show, status: :created, location: @container_member }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @container_member.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  def create_members
    binding.pry
    target_framework_folder = @framework_folder

    binding.pry
    service = Services::Frameworks::FrameworkMembers::CreateGroupOfMembers.new(new_framework_members_params,
                                                                               target_framework_folder)
    service.call
    binding.pry

    respond_to do |format|
      if service.errors.blank?
        ownername = service.target_framework_folder.related_framework.ownerable.ownername
        if target_framework_folder.root?
          success_path = framework_path(ownername: ownername,
                                        id: service.target_framework_folder.related_framework.slug)
        else
          success_path = framework_folder_path(ownername: ownername, id: @framework_folder.slug)
        end

        format.html { redirect_to success_path,
                                  notice: "Framework members was successfully added." }
        format.json { render :show, status: :created, location: service.framework }
      else
        format.html { render :new_members, status: :unprocessable_entity,
                             assigns: { target_framework_folder: @target_framework_folder,
                                        framework: service.target_framework_folder.related_framework } }
      end
    end
  end


  def destroy
    ownername = @framework_member.framework_folder.related_framework.ownerable.ownername
    if @framework_member.framework_folder.root?
      after_destroy_path = framework_path(ownername: ownername,
                                          id: @framework_member.framework_folder.related_framework.slug)
    else
      after_destroy_path = framework_folder_path(ownername: ownername,
                                          id: @framework_member.framework_folder.slug)
    end

    @framework_member.destroy

    respond_to do |format|
      format.html { redirect_to after_destroy_path, notice: "Framework member was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # def template
  #   binding.pry
  #   path = "framework/framework_members/form_partials/framework_member_dynamic_form"
  #
  #   form_object = Algorithms::Nodes::Step.new
  #
  #   form = SimpleForm::FormBuilder.new(
  #       "dynamic_node_#{Time.now.strftime("%I%M%S")}", # the scope for the inputs
  #       form_object,        # object wrapped by the form builder
  #       view_context,  # the template where the form builder can call the tag helpers on
  #       {}             # options
  #   )
  #
  #   template = render_to_string(
  #       partial: path,
  #       layout: false,
  #       locals: { form: form },
  #       formats: [:html]
  #   )
  #
  #   respond_to do |format|
  #     format.json {
  #       render json: { framework_member_template: template }
  #     }
  #   end
  # end

  # PATCH/PUT /container_members/1 or /container_members/1.json
  # def update
  #   respond_to do |format|
  #     if @container_member.update(container_member_params)
  #       format.html { redirect_to container_member_url(@container_member), notice: "Container member was successfully updated." }
  #       format.json { render :show, status: :ok, location: @container_member }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @container_member.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /container_members/1 or /container_members/1.json
  # def destroy
  #   @container_member.destroy
  #
  #   respond_to do |format|
  #     format.html { redirect_to container_members_url, notice: "Container member was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private

  def set_framework_member
    binding.pry
    @framework_member = Frameworks::FrameworkMember.friendly.try(:find, params[:id])

    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the post_path, and we should do
    # a 301 redirect that uses the current friendly id.
    request_slug = params[:id]
    if request_slug != @framework_member.slug
      return redirect_to framework_member_path(ownername: @framework_member.closest_framework.owner.ownername,
                                               id: @framework_member.slug),
                         :status => :moved_permanently
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Model not found"
    redirect_to :root
  end

  def set_framework
    binding.pry
    @framework = Frameworks::Framework.friendly.try(:find, params[:id])
  end

  def new_framework_members_params
    binding.pry
    params.require(:frameworks_framework).permit(
        framework_folder: [framework_members_attributes: [:framework_memberable_type, :framework_memberable_id]]
    )
  end

  def set_framework_folder
    @framework_folder = Frameworks::FrameworkFolder.find_by(uuid: params[:framework_folder]) ||
        Frameworks::FrameworkFolder.friendly.try(:find, params[:framework_folder])
  end

end
