class TagsController < ApplicationController

  def suggestions
    # params= {}
    # params[:keyword] = "a"
    # find_all = '*'
    # condition = {name: params[:keyword]}
    # @tags = Searchkick.search(find_all, where: condition, models: ActsAsTaggableOn::Tag)
    binding.pry
    query = params[:keyword]
    @tags = Searchkick.search(query, models: ActsAsTaggableOn::Tag, fields: [:name])
    results = @tags.map{|tag| tag.name}

    binding.pry
    respond_to do |format|
      format.json {
        render json: results
      }
    end
  end



end
