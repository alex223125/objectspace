# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ecosystems::LoadSources::Entity::EntityLifecycle do

  let(:entity) do
    create(
      :ecosystems_load_sources_entity,
      status: "draft",
      workflow_state: "approved",
      publish_at: nil
    )
  end

  let(:actor) do
    create(:user)
  end

  describe ".schedule_publish!" do

    it "stores the publish time" do
      publish_at = 1.hour.from_now

      described_class.schedule_publish!(
        entity: entity,
        publish_at: publish_at,
        actor: actor
      )

      entity.reload

      expect(entity.publish_at).to be_within(1.second).of(publish_at)
    end

    it "creates a scheduling event" do
      expect {
        described_class.schedule_publish!(
          entity: entity,
          publish_at: 1.hour.from_now,
          actor: actor
        )
      }.to change(
             Ecosystems::LoadSources::Entity::EntityEvent,
             :count
           ).by(1)

      event =
        Ecosystems::LoadSources::Entity::EntityEvent
          .order(:id)
          .last

      expect(event.event_type)
        .to eq("publish_scheduled")

      expect(event.actor_id)
        .to eq(actor.id)
    end

    it "does not allow a past publish time" do
      expect {
        described_class.schedule_publish!(
          entity: entity,
          publish_at: 1.hour.ago,
          actor: actor
        )
      }.to raise_error(
             described_class::InvalidState,
             "Publish time must be in the future."
           )
    end

  end

  describe ".unschedule_publish!" do

    before do
      entity.update!(
        publish_at: 1.hour.from_now
      )
    end

    it "clears publish_at" do
      described_class.unschedule_publish!(
        entity: entity,
        actor: actor
      )

      expect(entity.reload.publish_at)
        .to be_nil
    end

    it "creates a cancellation event" do
      expect {
        described_class.unschedule_publish!(
          entity: entity,
          actor: actor
        )
      }.to change(
             Ecosystems::LoadSources::Entity::EntityEvent,
             :count
           ).by(1)

      event =
        Ecosystems::LoadSources::Entity::EntityEvent
          .order(:id)
          .last

      expect(event.event_type)
        .to eq("publish_schedule_cancelled")
    end

  end

  describe ".publish!" do

    it "publishes the entity" do
      described_class.publish!(
        entity: entity,
        actor: actor
      )

      entity.reload

      expect(entity.status)
        .to eq("published")

      expect(entity.workflow_state)
        .to eq("published")

      expect(entity.published_at)
        .to be_present

      expect(entity.last_published_by_id)
        .to eq(actor.id)
    end

    it "creates a published event" do
      expect {
        described_class.publish!(
          entity: entity,
          actor: actor
        )
      }.to change(
             Ecosystems::LoadSources::Entity::EntityEvent,
             :count
           ).by(1)

      event =
        Ecosystems::LoadSources::Entity::EntityEvent
          .order(:id)
          .last

      expect(event.event_type)
        .to eq("published")
    end

    it "clears an existing schedule" do
      entity.update!(
        publish_at: 1.hour.from_now
      )

      described_class.publish!(
        entity: entity,
        actor: actor
      )

      expect(entity.reload.publish_at)
        .to be_nil
    end

  end

end