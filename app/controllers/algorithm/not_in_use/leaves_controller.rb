class LeavesController < ApplicationController
  before_action :set_leafe, only: %i[ show edit update destroy ]

  # GET /leaves or /leaves.json
  def index
    @leaves = Leafe.all
  end

  # GET /leaves/1 or /leaves/1.json
  def show
  end

  # GET /leaves/new
  def new
    @leafe = Leafe.new
  end

  # GET /leaves/1/edit
  def edit
  end

  # POST /leaves or /leaves.json
  def create
    @leafe = Leafe.new(leafe_params)

    respond_to do |format|
      if @leafe.save
        format.html { redirect_to leafe_url(@leafe), notice: "Leafe was successfully created." }
        format.json { render :show, status: :created, location: @leafe }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @leafe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /leaves/1 or /leaves/1.json
  def update
    respond_to do |format|
      if @leafe.update(leafe_params)
        format.html { redirect_to leafe_url(@leafe), notice: "Leafe was successfully updated." }
        format.json { render :show, status: :ok, location: @leafe }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @leafe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leaves/1 or /leaves/1.json
  def destroy
    @leafe.destroy

    respond_to do |format|
      format.html { redirect_to leaves_url, notice: "Leafe was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_leafe
      @leafe = Leafe.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def leafe_params
      params.require(:leafe).permit(:node_title)
    end
end
