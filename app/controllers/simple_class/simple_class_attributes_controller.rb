class SimpleClass::SimpleClassAttributesController < ApplicationController
  before_action :set_simple_class_attribute, only: %i[ show edit update destroy ]

  # GET /simple_class_attributes or /simple_class_attributes.json
  def index
    set_target_simple_class
    binding.pry
    @simple_class_attributes = @target_simple_class.simple_class_attributes
                                                   .includes(:actions, :article)
                                                   .preload(actions: :memberable)
                                                   .includes(article: :default_version)
  end

  # GET /simple_class_attributes/1 or /simple_class_attributes/1.json
  def show
  end

  # GET /simple_class_attributes/new
  def new
    binding.pry
    set_target_simple_class
    @simple_class_attribute = SimpleClasses::SimpleClassAttribute.new
  end

  # GET /simple_class_attributes/1/edit
  def edit
    @target_simple_class = @simple_class_attribute.simple_class
  end

  # POST /simple_class_attributes or /simple_class_attributes.json
  def create
    binding.pry

    @simple_class_attribute = SimpleClasses::SimpleClassAttribute.new(simple_class_attribute_params)

    binding.pry
    respond_to do |format|
      if @simple_class_attribute.save
        format.html { redirect_to simple_class_path(ownername: @simple_class_attribute.simple_class.owner.username,
                                                    id: @simple_class_attribute.simple_class.id),
                                  notice: "Attribute was successfully created." }
        format.json { render :show, status: :created, location: @simple_class_attribute }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @simple_class_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /simple_class_attributes/1 or /simple_class_attributes/1.json
  def update
    binding.pry
    service = Services::SimpleClasses::SimpleClassAttributes::Update.new(simple_class_attribute_params, @simple_class_attribute)
    service.call

    respond_to do |format|
      binding.pry
      if service.errors.blank?
        format.html { redirect_to simple_class_simple_class_attributes_path(target_simple_class: service.simple_class_attribute.simple_class),
                                  notice: "Attribute was successfully updated." }
        format.json { render :show, status: :ok, location: @simple_class_attribute }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: service.simple_class_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /simple_class_attributes/1 or /simple_class_attributes/1.json
  def destroy
    @simple_class_attribute.destroy

    respond_to do |format|
      format.html { redirect_to simple_class_attributes_url, notice: "Simple class attribute was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_target_simple_class
    @target_simple_class = SimpleClasses::SimpleClass.find(params[:target_simple_class])
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_simple_class_attribute
      @simple_class_attribute = SimpleClasses::SimpleClassAttribute.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def simple_class_attribute_params
      params.require(:simple_classes_simple_class_attribute).permit(:title, :description, :article_id, :simple_class_id, :actions)
    end

end
