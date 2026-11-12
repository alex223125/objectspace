module Admin
  module ResearchWorkspaces
    module ResearchActions
      extend ActiveSupport::Concern

      def add_annotation
        workspace = find_owned_workspace

        item = workspace.items.find(params[:item_id])

        annotation = item.annotations.create!(
          title: annotation_params[:title],
          body: annotation_params[:body],
          kind: annotation_params[:kind].presence || "expert_note",
          confidence: annotation_params[:confidence].presence || 50,
          status: "draft",
          author_name: annotation_params[:author_name],
          position: item.annotations.maximum(:position).to_i + 1
        )

        redirect_to admin_research_workspace_path(
                      workspace,
                      anchor: "item-#{item.id}"
                    ), notice: "Annotation saved."
      end

      def add_evidence
        workspace = find_owned_workspace

        item = workspace.items.find(params[:item_id])

        evidence = item.evidences.create!(
          title: evidence_params[:title],
          evidence_type: evidence_params[:evidence_type].presence || "source",
          source_name: evidence_params[:source_name],
          source_url: evidence_params[:source_url],
          summary: evidence_params[:summary],
          quote: evidence_params[:quote],
          published_at: evidence_params[:published_at],
          accessed_at: evidence_params[:accessed_at],
          confidence: evidence_params[:confidence].presence || 50,
          verified: false,
          position: item.evidences.maximum(:position).to_i + 1
        )

        redirect_to admin_research_workspace_path(
                      workspace,
                      anchor: "item-#{item.id}"
                    ), notice: "Evidence saved."
      end

      def verify_evidence
        workspace = find_owned_workspace

        evidence = workspace.research_workspace_evidences.find(
          params[:evidence_id]
        )

        evidence.verify!

        redirect_to admin_research_workspace_path(workspace),
                    notice: "Evidence verified."
      end

      def unverify_evidence
        workspace = find_owned_workspace

        evidence = workspace.research_workspace_evidences.find(
          params[:evidence_id]
        )

        evidence.unverify!

        redirect_to admin_research_workspace_path(workspace),
                    notice: "Evidence marked unverified."
      end

      def archive
        workspace = find_owned_workspace

        workspace.archive!

        redirect_to admin_research_workspaces_path,
                    notice: "Investigation archived."
      end

      def reactivate
        workspace = find_owned_workspace

        workspace.reactivate!

        redirect_to admin_research_workspace_path(workspace),
                    notice: "Investigation reactivated."
      end

      def finish
        workspace = find_owned_workspace

        workspace.complete!

        redirect_to admin_research_workspace_path(workspace),
                    notice: "Investigation completed."
      end

      private

      def find_owned_workspace
        owned_workspaces.find(params[:id])
      end

      def annotation_params
        params.require(:annotation).permit(
          :title,
          :body,
          :kind,
          :confidence,
          :author_name
        )
      end

      def evidence_params
        params.require(:evidence).permit(
          :title,
          :evidence_type,
          :source_name,
          :source_url,
          :summary,
          :quote,
          :published_at,
          :accessed_at,
          :confidence
        )
      end
    end
  end
end