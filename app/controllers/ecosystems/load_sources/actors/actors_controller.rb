module Ecosystems
  module LoadSources
    module Actors
      class ActorsController < ApplicationController

        before_action :set_actor, only: %i[show edit update destroy]

        def index
          @actors = Ecosystems::LoadSources::Actors::Actor
                      .order(created_at: :desc)
                      .limit(20)
        end

        def search
          query = params[:q].to_s.strip

          if query.blank?
            actors = Ecosystems::LoadSources::Actors::Actor
                       .order(created_at: :desc)
                       .limit(20)
          else
            actors = Ecosystems::LoadSources::Actors::Actor
                       .search(
                         query,
                         fields: [:name, :description],
                         limit: 20
                       )
                       .results
          end

          render json: {
            actors: actors.map do |actor|
              {
                id: actor.id,
                name: actor.name,
                slug: actor.slug,
                description: actor.description,
                status: actor.status,
                url: ecosystems_load_sources_actors_actor_path(actor)
              }
            end,
            count: actors.size,
            query: query
          }
        end

        def show
        end

        def new
          @actor = Ecosystems::LoadSources::Actors::Actor.new
        end

        def create
          @actor = Ecosystems::LoadSources::Actors::Actor.new(actor_params)

          if @actor.save
            redirect_to actor_path(@actor),
                        notice: "Actor created successfully."
          else
            render :new, status: :unprocessable_entity
          end
        end

        def edit
        end

        def update
          if @actor.update(actor_params)
            redirect_to actor_path(@actor),
                        notice: "Actor updated successfully."
          else
            render :edit, status: :unprocessable_entity
          end
        end

        def destroy
          @actor.destroy

          redirect_to actors_path,
                      notice: "Actor deleted successfully."
        end

        private

        def set_actor
          @actor = Ecosystems::LoadSources::Actors::Actor.find(params[:id])
        end

        def actor_params
          params.require(
            :ecosystems_load_sources_actors_actor
          ).permit(
            :name,
            :slug,
            :description,
            :status
          )
        end

        def actor_path(actor)
          ecosystems_load_sources_actors_actor_path(actor)
        end

        def actors_path
          ecosystems_load_sources_actors_actors_path
        end

      end
    end
  end
end