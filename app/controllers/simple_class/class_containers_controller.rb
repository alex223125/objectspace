class SimpleClass::ClassContainersController < ApplicationController
  before_action :set_class_container, only: %i[ show edit update destroy ]

  # GET /class_containers or /class_containers.json
  def index
    @class_containers = SimpleClasses::ClassContainer.all
  end

  # GET /class_containers/1 or /class_containers/1.json
  def show
  end

  # GET /class_containers/new
  def new
    @class_container = SimpleClasses::ClassContainer.new
  end

  # GET /class_containers/1/edit
  def edit
  end

  # POST /class_containers or /class_containers.json
  def create
    @class_container = SimpleClasses::ClassContainer.new(class_container_params)

    respond_to do |format|
      if @class_container.save
        format.html { redirect_to class_container_url(@class_container), notice: "Class container was successfully created." }
        format.json { render :show, status: :created, location: @class_container }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @class_container.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /class_containers/1 or /class_containers/1.json
  def update
    respond_to do |format|
      if @class_container.update(class_container_params)
        format.html { redirect_to class_container_url(@class_container), notice: "Class container was successfully updated." }
        format.json { render :show, status: :ok, location: @class_container }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @class_container.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /class_containers/1 or /class_containers/1.json
  def destroy
    @class_container.destroy

    respond_to do |format|
      format.html { redirect_to class_containers_url, notice: "Class container was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_class_container
      @class_container = SimpleClasses::ClassContainer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def class_container_params
      params.require(:class_container).permit(:title, :description)
    end
end
