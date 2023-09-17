class SimpleClass::InterfaceMembersController < ApplicationController
  before_action :set_interface_member, only: %i[ show edit update destroy ]

  # GET /interface_members or /interface_members.json
  # def index
  #   @interface_members = SimpleClasses::InterfaceMember.all
  # end

  # GET /interface_members/1 or /interface_members/1.json
  # def show
  # end

  def preview
    if @interface_member.memberable_type == "Units::Unit"
      path = "shared/technologies_search/dpo_instruction_select/preview/unit"
    elsif @interface_member.memberable_type == "Algorithms::Algorithm"
      path = "shared/technologies_search/dpo_instruction_select/preview/algorithm"
    end

    respond_to do |format|
      format.json {
        render json: { preview: render_to_string(partial: path,
                                                 formats: [:html])}
      }
    end
  end

  # GET /interface_members/new
  # def new
  #   @interface_member = SimpleClasses::InterfaceMember.new
  # end

  # GET /interface_members/1/edit
  # def edit
  # end

  # POST /interface_members or /interface_members.json
  # def create
  #   @interface_member = SimpleClasses::InterfaceMember.new(interface_member_params)
  #
  #   respond_to do |format|
  #     if @interface_member.save
  #       format.html { redirect_to interface_member_url(@interface_member), notice: "Interface member was successfully created." }
  #       format.json { render :show, status: :created, location: @interface_member }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @interface_member.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /interface_members/1 or /interface_members/1.json
  # def update
  #   respond_to do |format|
  #     if @interface_member.update(interface_member_params)
  #       format.html { redirect_to interface_member_url(@interface_member), notice: "Interface member was successfully updated." }
  #       format.json { render :show, status: :ok, location: @interface_member }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @interface_member.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /interface_members/1 or /interface_members/1.json
  # def destroy
  #   @interface_member.destroy
  #
  #   respond_to do |format|
  #     format.html { redirect_to interface_members_url, notice: "Interface member was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interface_member
      @interface_member = SimpleClasses::InterfaceMember.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    # def interface_member_params
    #   params.fetch(:interface_member, {})
    # end
end
