class AlgorithmTreesController < ApplicationController
  before_action :set_algorithm_tree, only: %i[ show edit update destroy ]

  # GET /algorithm_trees or /algorithm_trees.json
  def index
    @algorithm_trees = AlgorithmTree.all
  end

  # GET /algorithm_trees/1 or /algorithm_trees/1.json
  def show
  end

  # GET /algorithm_trees/new
  def new
    @algorithm_tree = AlgorithmTree.new
  end

  # GET /algorithm_trees/1/edit
  def edit
  end

  # POST /algorithm_trees or /algorithm_trees.json
  def create
    @algorithm_tree = AlgorithmTree.new(algorithm_tree_params)

    respond_to do |format|
      if @algorithm_tree.save
        format.html { redirect_to algorithm_tree_url(@algorithm_tree), notice: "Algorithm tree was successfully created." }
        format.json { render :show, status: :created, location: @algorithm_tree }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @algorithm_tree.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /algorithm_trees/1 or /algorithm_trees/1.json
  def update
    respond_to do |format|
      if @algorithm_tree.update(algorithm_tree_params)
        format.html { redirect_to algorithm_tree_url(@algorithm_tree), notice: "Algorithm tree was successfully updated." }
        format.json { render :show, status: :ok, location: @algorithm_tree }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @algorithm_tree.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /algorithm_trees/1 or /algorithm_trees/1.json
  def destroy
    @algorithm_tree.destroy

    respond_to do |format|
      format.html { redirect_to algorithm_trees_url, notice: "Algorithm tree was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_algorithm_tree
      @algorithm_tree = AlgorithmTree.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def algorithm_tree_params
      params.require(:algorithm_tree).permit(:algorithm_version_title)
    end
end
