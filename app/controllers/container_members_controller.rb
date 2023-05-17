class ContainerMembersController < ApplicationController
  before_action :set_container_member, only: %i[ show edit update destroy ]

  # GET /container_members or /container_members.json
  def index
    @container_members = ContainerMember.all
  end

  # GET /container_members/1 or /container_members/1.json
  def show
  end

  # GET /container_members/new
  def new
    @container_member = ContainerMember.new
  end

  # GET /container_members/1/edit
  def edit
  end

  # POST /container_members or /container_members.json
  def create
    @container_member = ContainerMember.new(container_member_params)

    respond_to do |format|
      if @container_member.save
        format.html { redirect_to container_member_url(@container_member), notice: "Container member was successfully created." }
        format.json { render :show, status: :created, location: @container_member }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @container_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /container_members/1 or /container_members/1.json
  def update
    respond_to do |format|
      if @container_member.update(container_member_params)
        format.html { redirect_to container_member_url(@container_member), notice: "Container member was successfully updated." }
        format.json { render :show, status: :ok, location: @container_member }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @container_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /container_members/1 or /container_members/1.json
  def destroy
    @container_member.destroy

    respond_to do |format|
      format.html { redirect_to container_members_url, notice: "Container member was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_container_member
      @container_member = ContainerMember.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def container_member_params
      params.fetch(:container_member, {})
    end
end
