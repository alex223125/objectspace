
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "entityType",
    "relationshipType",
    "resultCount",
    "activeBadge",
    "message",
    "panel",
  ];

  connect() {
    this.populateOptions();
    this.applyFilters(false);
  }

  get directoryRecords() {
    return Array.from(
        document.querySelectorAll(
            "article[data-graph-directory-record][data-entity-id][data-entity-name]"
        )
    );
  }

  getRecordType(record) {
    return String(record.dataset.entityType || "").trim();
  }

  getRelationshipTypes(record) {
    try {
      const parsed = JSON.parse(
          record.dataset.entityRelationships || "[]"
      );

      const relationships = Array.isArray(parsed)
          ? parsed
          : parsed
              ? [parsed]
              : [];

      return relationships
          .map((relationship) => {
            if (typeof relationship === "string") {
              return relationship.trim();
            }

            if (relationship && typeof relationship === "object") {
              return String(
                  relationship.type ??
                  relationship.relationship_type ??
                  relationship.label ??
                  relationship.kind ??
                  ""
              ).trim();
            }

            return "";
          })
          .filter(Boolean);
    } catch (error) {
      console.warn(
          "[GraphFilters] Could not read relationship metadata:",
          record.dataset.entityId,
          error
      );

      return [];
    }
  }

  populateOptions() {
    const records = this.directoryRecords;

    this.replaceOptions(
        this.entityTypeTarget,
        records.map((record) => this.getRecordType(record)),
        "All entity types"
    );

    this.replaceOptions(
        this.relationshipTypeTarget,
        records.flatMap((record) =>
            this.getRelationshipTypes(record)
        ),
        "All relationship types"
    );
  }

  replaceOptions(select, values, placeholder) {
    const previousValue = select.value;

    const uniqueValues = [
      ...new Set(values.filter(Boolean)),
    ].sort((a, b) => a.localeCompare(b));

    const fragment = document.createDocumentFragment();
    const firstOption = document.createElement("option");

    firstOption.value = "";
    firstOption.textContent = placeholder;
    fragment.append(firstOption);

    uniqueValues.forEach((value) => {
      const option = document.createElement("option");

      option.value = value;
      option.textContent = value;

      fragment.append(option);
    });

    select.replaceChildren(fragment);

    if (uniqueValues.includes(previousValue)) {
      select.value = previousValue;
    }
  }

  readFilters() {
    return {
      entityType: this.entityTypeTarget.value,
      relationshipType: this.relationshipTypeTarget.value,
    };
  }

  matchesRecord(record, filters) {
    if (
        filters.entityType &&
        this.getRecordType(record) !== filters.entityType
    ) {
      return false;
    }

    if (
        filters.relationshipType &&
        !this.getRelationshipTypes(record).includes(
            filters.relationshipType
        )
    ) {
      return false;
    }

    return true;
  }

  preview() {
    const filters = this.readFilters();
    const records = this.directoryRecords;

    const matchingCount = records.filter((record) =>
        this.matchesRecord(record, filters)
    ).length;

    this.resultCountTarget.textContent =
        `${matchingCount} of ${records.length} records match`;

    this.messageTarget.textContent =
        "Preview updated. Click Apply filters to update the directory.";
  }

  apply(event) {
    event.preventDefault();
    event.stopPropagation();

    this.applyFilters(true);
  }

  applyFilters(announce = true) {
    const filters = this.readFilters();
    const records = this.directoryRecords;

    let matchingCount = 0;

    records.forEach((record) => {
      const visible = this.matchesRecord(record, filters);

      record.hidden = !visible;
      record.setAttribute("aria-hidden", String(!visible));

      if (visible) {
        matchingCount += 1;
      }
    });

    const activeCount = [
      filters.entityType,
      filters.relationshipType,
    ].filter(Boolean).length;

    this.resultCountTarget.textContent =
        `${matchingCount} of ${records.length} records`;

    this.activeBadgeTarget.textContent =
        activeCount === 0
            ? "No active filters"
            : `${activeCount} active ${
                activeCount === 1 ? "filter" : "filters"
            }`;

    if (announce) {
      this.messageTarget.textContent =
          "Filters applied. The page and filter panel remain available.";
    }
  }

  reset(event) {
    event.preventDefault();
    event.stopPropagation();

    this.entityTypeTarget.value = "";
    this.relationshipTypeTarget.value = "";

    this.applyFilters(false);

    this.messageTarget.textContent =
        "Filters cleared. All directory records are shown.";
  }

  refresh() {
    this.populateOptions();
    this.applyFilters(false);
  }
}