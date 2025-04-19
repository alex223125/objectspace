class SimpleClassInterfacesController < ApplicationController
  before_action :set_simple_class_interface, only: %i[ show edit update destroy ]

  # GET /simple_class_interfaces or /simple_class_interfaces.json
  def index
    @simple_class_interfaces = SimpleClassInterface.all
  end

  # GET /simple_class_interfaces/1 or /simple_class_interfaces/1.json
  def show
  end

  # GET /simple_class_interfaces/new
  def new
    @simple_class_interface = SimpleClassInterface.new
  end

  # GET /simple_class_interfaces/1/edit
  def edit
  end

  # POST /simple_class_interfaces or /simple_class_interfaces.json
  def create
    @simple_class_interface = SimpleClassInterface.new(simple_class_interface_params)

    respond_to do |format|
      if @simple_class_interface.save
        format.html { redirect_to simple_class_interface_url(@simple_class_interface), notice: "Simple class interface was successfully created." }
        format.json { render :show, status: :created, location: @simple_class_interface }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @simple_class_interface.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /simple_class_interfaces/1 or /simple_class_interfaces/1.json
  def update
    respond_to do |format|
      if @simple_class_interface.update(simple_class_interface_params)
        format.html { redirect_to simple_class_interface_url(@simple_class_interface), notice: "Simple class interface was successfully updated." }
        format.json { render :show, status: :ok, location: @simple_class_interface }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @simple_class_interface.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /simple_class_interfaces/1 or /simple_class_interfaces/1.json
  def destroy
    @simple_class_interface.destroy

    respond_to do |format|
      format.html { redirect_to simple_class_interfaces_url, notice: "Simple class interface was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_simple_class_interface
      @simple_class_interface = SimpleClassInterface.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def simple_class_interface_params
      params.require(:simple_class_interface).permit(:note)
    end
end
