# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ecosystems::LoadSources::Entity::PublishScheduledEntityJob,
               type: :job do

  let(:entity) do
    create(
      :ecosystems_load_sources_entity,
      status: "draft",
      workflow_state: "approved",
      publish_at: 1.hour.ago
    )
  end

  it "publishes a scheduled entity" do
    described_class.perform_now(entity.id)

    entity.reload

    expect(entity.status)
      .to eq("published")

    expect(entity.workflow_state)
      .to eq("published")

    expect(entity.published_at)
      .to be_present
  end

  it "does nothing when the entity is already published" do
    entity.update!(
      status: "published",
      workflow_state: "published",
      published_at: Time.current
    )

    expect {
      described_class.perform_now(entity.id)
    }.not_to change(
               Ecosystems::LoadSources::Entity::EntityEvent,
               :count
             )
  end

  it "does not publish before the scheduled time" do
    entity.update!(
      publish_at: 1.hour.from_now
    )

    expect {
      described_class.perform_now(entity.id)
    }.not_to change(
               Ecosystems::LoadSources::Entity::EntityEvent,
               :count
             )

    expect(entity.reload.status)
      .to eq("draft")
  end

end