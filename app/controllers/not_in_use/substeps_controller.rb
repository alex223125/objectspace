class SubstepsController < ApplicationController
  before_action :set_substep, only: %i[ show edit update destroy ]

  # GET /substeps or /substeps.json
  def index
    @substeps = Substep.all
  end

  # GET /substeps/1 or /substeps/1.json
  def show
  end

  # GET /substeps/new
  def new
    @substep = Substep.new
  end

  # GET /substeps/1/edit
  def edit
  end

  # POST /substeps or /substeps.json
  def create
    @substep = Substep.new(substep_params)

    respond_to do |format|
      if @substep.save
        format.html { redirect_to substep_url(@substep), notice: "Substep was successfully created." }
        format.json { render :show, status: :created, location: @substep }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @substep.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /substeps/1 or /substeps/1.json
  def update
    respond_to do |format|
      if @substep.update(substep_params)
        format.html { redirect_to substep_url(@substep), notice: "Substep was successfully updated." }
        format.json { render :show, status: :ok, location: @substep }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @substep.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /substeps/1 or /substeps/1.json
  def destroy
    @substep.destroy

    respond_to do |format|
      format.html { redirect_to substeps_url, notice: "Substep was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_substep
      @substep = Substep.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def substep_params
      params.require(:substep).permit(:type)
    end
end
