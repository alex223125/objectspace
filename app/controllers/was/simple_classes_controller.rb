class SimpleClass::SimpleClassesController < ApplicationController
  before_action :set_simple_object, only: %i[ show edit update destroy ]

  # GET /simple_objects or /simple_objects.json
  def index
    @simple_objects = SimpleClasses::SimpleClass.all
  end

  # GET /simple_objects/1 or /simple_objects/1.json
  def show
  end

  # GET /simple_objects/new
  def new
    @simple_object = SimpleClasses::SimpleClass.new
  end

  # GET /simple_objects/1/edit
  def edit
  end

  # POST /simple_objects or /simple_objects.json
  def create
    binding.pry
    @simple_object = SimpleClasses::SimpleClass.new(simple_object_params)


    binding.pry
    respond_to do |format|
      if @simple_object.save
        # format.html { redirect_to simple_object_url(@simple_object), notice: "Simple object was successfully created." }
        format.html { redirect_to simple_object_simple_object_path(@simple_object), notice: "Simple object was successfully created." }
        format.json { render :show, status: :created, location: @simple_object }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @simple_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /simple_objects/1 or /simple_objects/1.json
  def update
    respond_to do |format|
      if @simple_object.update(simple_object_params)
        format.html { redirect_to simple_object_url(@simple_object), notice: "Simple object was successfully updated." }
        format.json { render :show, status: :ok, location: @simple_object }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @simple_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /simple_objects/1 or /simple_objects/1.json
  def destroy
    @simple_object.destroy

    respond_to do |format|
      format.html { redirect_to simple_objects_url, notice: "Simple object was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_simple_object
      @simple_object = SimpleObjects::SimpleObject.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def simple_object_params
      params.require(:simple_objects_simple_object).permit(:title, :description, :type, :instructionable_type, :instructionable_id )
    end
end
