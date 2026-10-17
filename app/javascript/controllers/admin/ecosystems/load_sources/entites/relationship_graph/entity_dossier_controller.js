
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "title",
    "summary",
    "identifier",
    "status",
    "type",
    "metadata",
    "empty"
  ]

  connect() {
    this.onEntitySelected = (event) => {
      if (event.detail?.entity) {
        this.render(event.detail.entity)
      }
    }

    this.element.addEventListener(
        "relationship-graph:entity-selected",
        this.onEntitySelected
    )
  }

  disconnect() {
    this.element.removeEventListener(
        "relationship-graph:entity-selected",
        this.onEntitySelected
    )
  }

  render(entity) {
    if (this.hasTitleTarget) {
      this.titleTarget.textContent = entity.name || `Entity ${entity.id ?? ""}`
    }

    if (this.hasSummaryTarget) {
      this.summaryTarget.textContent =
          entity.summary || "No summary has been provided."
    }

    if (this.hasIdentifierTarget) {
      this.identifierTarget.textContent =
          entity.id === null || entity.id === undefined
              ? "Unavailable"
              : String(entity.id)
    }

    if (this.hasStatusTarget) {
      this.statusTarget.textContent =
          entity.status || entity.workflow_state || "Unknown"
    }

    if (this.hasTypeTarget) {
      this.typeTarget.textContent =
          entity.entity_type_name ||
          entity.entity_type ||
          entity.entity_type_id ||
          "Unclassified"
    }

    if (this.hasMetadataTarget) {
      this.renderMetadata(entity)
    }

    if (this.hasEmptyTarget) {
      this.emptyTarget.hidden = true
    }

    this.element.dispatchEvent(
        new CustomEvent("relationship-graph:dossier-rendered", {
          bubbles: true,
          detail: { entityId: entity.id }
        })
    )
  }

  renderMetadata(entity) {
    const allowedFields = [
      ["Slug", "slug"],
      ["Workflow state", "workflow_state"],
      ["Updated at", "updated_at"]
    ]

    const fragment = document.createDocumentFragment()

    allowedFields.forEach(([label, key]) => {
      const value = entity[key]

      if (value === null || value === undefined || value === "") {
        return
      }

      const row = document.createElement("div")
      row.className =
          "grid grid-cols-1 gap-1 border-b border-orange-100 py-3 sm:grid-cols-[140px_minmax(0,1fr)]"

      const term = document.createElement("dt")
      term.className = "text-sm font-bold text-slate-500"
      term.textContent = label

      const detail = document.createElement("dd")
      detail.className = "break-words text-sm font-semibold text-slate-800"
      detail.textContent = String(value)

      row.append(term, detail)
      fragment.append(row)
    })

    this.metadataTarget.replaceChildren(fragment)
  }

  showEmpty() {
    if (this.hasEmptyTarget) {
      this.emptyTarget.hidden = false
    }
  }
}