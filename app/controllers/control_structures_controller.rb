class ControlStructuresController < ApplicationController
  before_action :set_control_structure, only: %i[ show edit update destroy ]

  # GET /control_structures or /control_structures.json
  def index
    @control_structures = ControlStructure.all
  end

  # GET /control_structures/1 or /control_structures/1.json
  def show
  end

  # GET /control_structures/new
  def new
    @control_structure = ControlStructure.new
  end

  # GET /control_structures/1/edit
  def edit
  end

  # POST /control_structures or /control_structures.json
  def create
    @control_structure = ControlStructure.new(control_structure_params)

    respond_to do |format|
      if @control_structure.save
        format.html { redirect_to control_structure_url(@control_structure), notice: "Control structure was successfully created." }
        format.json { render :show, status: :created, location: @control_structure }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @control_structure.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /control_structures/1 or /control_structures/1.json
  def update
    respond_to do |format|
      if @control_structure.update(control_structure_params)
        format.html { redirect_to control_structure_url(@control_structure), notice: "Control structure was successfully updated." }
        format.json { render :show, status: :ok, location: @control_structure }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @control_structure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /control_structures/1 or /control_structures/1.json
  def destroy
    @control_structure.destroy

    respond_to do |format|
      format.html { redirect_to control_structures_url, notice: "Control structure was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_control_structure
      @control_structure = ControlStructure.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def control_structure_params
      params.require(:control_structure).permit(:type)
    end
end
