# frozen_string_literal: true

class AddApprovalInvalidatedEventType < ActiveRecord::Migration[7.0]

  def up
    # No database change is required when event_type is a string.
    #
    # Keep this migration as a placeholder only if your application
    # uses database-level event type constraints.
  end

  def down
    # Nothing to reverse.
  end

end