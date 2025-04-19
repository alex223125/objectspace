class LoggingNodesController < ApplicationController
  before_action :set_logging_node, only: %i[ show edit update destroy ]

  # GET /logging_nodes or /logging_nodes.json
  def index
    @logging_nodes = LoggingNode.all
  end

  # GET /logging_nodes/1 or /logging_nodes/1.json
  def show
  end

  # GET /logging_nodes/new
  def new
    @logging_node = LoggingNode.new
  end

  # GET /logging_nodes/1/edit
  def edit
  end

  # POST /logging_nodes or /logging_nodes.json
  def create
    @logging_node = LoggingNode.new(logging_node_params)

    respond_to do |format|
      if @logging_node.save
        format.html { redirect_to logging_node_url(@logging_node), notice: "Logging node was successfully created." }
        format.json { render :show, status: :created, location: @logging_node }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @logging_node.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /logging_nodes/1 or /logging_nodes/1.json
  def update
    respond_to do |format|
      if @logging_node.update(logging_node_params)
        format.html { redirect_to logging_node_url(@logging_node), notice: "Logging node was successfully updated." }
        format.json { render :show, status: :ok, location: @logging_node }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @logging_node.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /logging_nodes/1 or /logging_nodes/1.json
  def destroy
    @logging_node.destroy

    respond_to do |format|
      format.html { redirect_to logging_nodes_url, notice: "Logging node was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_logging_node
      @logging_node = LoggingNode.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def logging_node_params
      params.require(:logging_node).permit(:type, :position)
    end
end
