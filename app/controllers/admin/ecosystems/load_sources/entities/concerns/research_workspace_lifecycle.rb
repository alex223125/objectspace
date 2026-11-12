module Admin::ResearchWorkspaceLifecycle
  extend ActiveSupport::Concern

  included do
    before_action :set_lifecycle_workspace,
                  only: %i[
                    resume
                    reopen
                    complete
                    archive
                    save_checkpoint
                    snapshots
                    history
                  ]
  end

  def saved
    @investigation_filter = params[:filter].presence || "all"

    scope = owned_workspaces
              .includes(:items, :research_annotations, :research_evidences)
              .saved_investigations

    @investigations = case @investigation_filter
                      when "active"
                        scope.where(status: "active")
                      when "completed"
                        scope.where(status: "completed")
                      when "archived"
                        scope.where(status: "archived")
                      else
                        scope
                      end

    @investigations = @investigations
                        .order(last_opened_at: :desc, updated_at: :desc)

    @investigation_counts = {
      all: scope.count,
      active: scope.where(status: "active").count,
      completed: scope.where(status: "completed").count,
      archived: scope.where(status: "archived").count
    }
  end

  def resume
    @workspace.resume!

    redirect_to admin_research_workspace_path(@workspace),
                notice: "Investigation resumed."
  end

  def reopen
    @workspace.reopen!

    redirect_to admin_research_workspace_path(@workspace),
                notice: "Investigation reopened."
  end

  def complete
    @workspace.complete!

    redirect_to admin_research_workspace_path(@workspace),
                notice: "Investigation marked as completed."
  end

  def archive
    @workspace.archive!

    redirect_to admin_research_workspace_path(@workspace),
                notice: "Investigation archived."
  end

  def save_checkpoint
    snapshot = @workspace.save_checkpoint!(
      label: params[:label].presence
    )

    redirect_to snapshots_admin_research_workspace_path(@workspace),
                notice: "Checkpoint saved: #{snapshot['label']}."
  end

  def snapshots
    @snapshots = @workspace.snapshots
  end

  def history
    @history = @workspace.history
  end

  private

  def set_lifecycle_workspace
    @workspace = owned_workspaces.find(params[:id])

    @workspace.mark_opened! if action_name.in?(%w[resume reopen])
  end
end