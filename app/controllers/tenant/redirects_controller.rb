module Tenant
  class RedirectsController < ApplicationController
    skip_before_action :authenticate_user!

    def show
      asset = TenantQrAsset.find_by!(lookup_hash: params[:token])
      developer = asset.algorithm_version.creator

      # Award gamified telemetry metrics asynchronously
      DeveloperTelemetryJob.perform_later(developer_id: developer.id, xp: 50)

      redirect_to asset.algorithm_version.target_destination_url, allow_other_host: true
    end
  end
end
