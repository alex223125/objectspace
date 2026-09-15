import { Controller } from "@hotwired/stimulus"

/*
 * Definition Library Controller
 *
 * Debug console prefixes:
 *
 *   [DEFINITION LIBRARY]
 *   [DEFINITION LIBRARY:CATALOG]
 *   [DEFINITION LIBRARY:SEARCH]
 *   [DEFINITION LIBRARY:PREVIEW]
 *   [DEFINITION LIBRARY:APPLY]
 */

export default class extends Controller {
  static targets = [
    "modal",
    "backdrop",
    "dialog",

    "search",
    "clearSearch",
    "sortButton",
    "resultCount",
    "categories",
    "grid",
    "emptyState",

    "status",

    "previewEmpty",
    "preview",

    "previewIcon",
    "previewTitle",
    "previewCategory",
    "previewId",
    "previewDescription",

    "previewFieldCount",
    "previewRequiredCount",
    "previewActiveCount",

    "fieldsTab",
    "jsonTab",
    "fieldsPanel",
    "jsonPanel",

    "previewFieldSummary",
    "fieldList",
    "previewJson",

    "applyButton"
  ]

  static values = {
    catalog: {
      type: Array,
      default: []
    }
  }

  connect() {
    this.debug("CONNECT", {
      identifier: this.identifier,
      element: this.element,
      controllerAttribute:
        this.element?.getAttribute(
          "data-controller"
        )
    })

    this.debugTargetInventory()

    this.selectedDefinition = null
    this.currentCategory = "ALL"
    this.sortMode = "az"

    this.debugCatalog(
      "Initial catalog value",
      this.catalogValue
    )

    this.renderCategories()
    this.renderCatalog()
    this.showEmptyPreview()

    this.debug(
      "CONNECT COMPLETE"
    )
  }

  disconnect() {
    this.debug(
      "DISCONNECT"
    )
  }

  // ============================================================
  // DEBUG
  // ============================================================

  get debugEnabled() {
    return window.DEFINITION_LIBRARY_DEBUG !== false
  }

  debug(message, payload = undefined) {
    if (!this.debugEnabled) return

    if (payload === undefined) {
      console.log(
        `[DEFINITION LIBRARY] ${message}`
      )
    } else {
      console.log(
        `[DEFINITION LIBRARY] ${message}`,
        payload
      )
    }
  }

  debugCatalog(message, payload = undefined) {
    if (!this.debugEnabled) return

    if (payload === undefined) {
      console.log(
        `[DEFINITION LIBRARY:CATALOG] ${message}`
      )
    } else {
      console.log(
        `[DEFINITION LIBRARY:CATALOG] ${message}`,
        payload
      )
    }
  }

  debugSearch(message, payload = undefined) {
    if (!this.debugEnabled) return

    if (payload === undefined) {
      console.log(
        `[DEFINITION LIBRARY:SEARCH] ${message}`
      )
    } else {
      console.log(
        `[DEFINITION LIBRARY:SEARCH] ${message}`,
        payload
      )
    }
  }

  debugPreview(message, payload = undefined) {
    if (!this.debugEnabled) return

    if (payload === undefined) {
      console.log(
        `[DEFINITION LIBRARY:PREVIEW] ${message}`
      )
    } else {
      console.log(
        `[DEFINITION LIBRARY:PREVIEW] ${message}`,
        payload
      )
    }
  }

  debugApply(message, payload = undefined) {
    if (!this.debugEnabled) return

    if (payload === undefined) {
      console.log(
        `[DEFINITION LIBRARY:APPLY] ${message}`
      )
    } else {
      console.log(
        `[DEFINITION LIBRARY:APPLY] ${message}`,
        payload
      )
    }
  }

  debugTargetInventory() {
    const targetNames = [
      "modal",
      "search",
      "grid",
      "categories",
      "preview",
      "previewEmpty",
      "applyButton"
    ]

    const result = {}

    targetNames.forEach((name) => {
      const property =
        `has${name.charAt(0).toUpperCase()}${name.slice(1)}Target`

      result[name] =
        this[property] ?? false
    })

    this.debug(
      "TARGET INVENTORY",
      result
    )
  }

  // ============================================================
  // OPEN / CLOSE
  // ============================================================

  open(event) {
    event?.preventDefault()

    this.debug(
      "OPEN action/event received",
      {
        eventType: event?.type,
        detail: event?.detail
      }
    )

    if (!this.hasModalTarget) {
      this.debug(
        "ERROR: modal target missing"
      )
      return
    }

    this.modalTarget.classList.remove(
      "hidden"
    )

    this.modalTarget.setAttribute(
      "aria-hidden",
      "false"
    )

    document.body.classList.add(
      "overflow-hidden"
    )

    this.debug(
      "Modal is now visible"
    )

    if (this.hasSearchTarget) {
      requestAnimationFrame(() => {
        this.searchTarget.focus()
      })
    }

    this.renderCatalog()
  }

  close(event) {
    event?.preventDefault()

    this.debug(
      "CLOSE action/event received",
      {
        eventType: event?.type
      }
    )

    if (!this.hasModalTarget) {
      this.debug(
        "ERROR: modal target missing"
      )
      return
    }

    this.modalTarget.classList.add(
      "hidden"
    )

    this.modalTarget.setAttribute(
      "aria-hidden",
      "true"
    )

    document.body.classList.remove(
      "overflow-hidden"
    )

    this.debug(
      "Modal closed"
    )
  }

  // ============================================================
  // CATALOG
  // ============================================================

  catalogValueChanged(current, previous) {
    this.debugCatalog(
      "catalogValueChanged",
      {
        current,
        previous
      }
    )

    if (this.element.isConnected) {
      this.renderCategories()
      this.renderCatalog()
    }
  }

  get catalog() {
    const value = this.catalogValue

    if (!Array.isArray(value)) {
      this.debugCatalog(
        "Catalog value is not an array",
        value
      )

      return []
    }

    return value
  }

  get filteredCatalog() {
    const query = this.hasSearchTarget
      ? this.searchTarget.value
          .trim()
          .toLowerCase()
      : ""

    let result = [...this.catalog]

    if (this.currentCategory !== "ALL") {
      result = result.filter(
        (definition) =>
          String(
            definition.category || ""
          ).toUpperCase() ===
          this.currentCategory
      )
    }

    if (query) {
      result = result.filter(
        (definition) =>
          this.searchableText(
            definition
          ).includes(query)
      )
    }

    result.sort((a, b) => {
      const aName =
        String(
          a.name ||
          a.title ||
          a.id ||
          ""
        ).toLowerCase()

      const bName =
        String(
          b.name ||
          b.title ||
          b.id ||
          ""
        ).toLowerCase()

      return aName.localeCompare(
        bName
      )
    })

    return result
  }

  searchableText(definition) {
    const fields =
      Array.isArray(definition.fields)
        ? definition.fields
        : []

    return [
      definition.id,
      definition.name,
      definition.title,
      definition.description,
      definition.category,
      ...fields.flatMap(
        (field) => [
          field.name,
          field.label,
          field.description,
          field.type
        ]
      )
    ]
      .filter(Boolean)
      .join(" ")
      .toLowerCase()
  }

  renderCategories() {
    if (!this.hasCategoriesTarget) {
      this.debugCatalog(
        "categories target missing"
      )
      return
    }

    const categories = [
      "ALL",
      ...new Set(
        this.catalog
          .map((definition) =>
            String(
              definition.category || ""
            )
              .trim()
              .toUpperCase()
          )
          .filter(Boolean)
      )
    ]

    this.debugCatalog(
      "Rendering categories",
      categories
    )

    this.categoriesTarget.innerHTML =
      categories
        .map((category) => {
          const active =
            category ===
            this.currentCategory

          return `
<button
type="button"
class="shrink-0 rounded-xl border-2 px-3 py-2 text-[8px] font-black uppercase tracking-wider transition ${
active
    ? "border-violet-300 bg-violet-100 text-violet-600"
    : "border-slate-100 bg-white text-slate-400 hover:border-violet-200 hover:text-violet-500"
}"
data-category="${this.escapeHtml(category)}"
data-action="click->definition-library#selectCategory"
    >
    ${this.escapeHtml(category)}
</button>
`
        })
        .join("")
  }

  selectCategory(event) {
    event?.preventDefault()

    const category =
      event?.currentTarget?.dataset?.category

    this.debugSearch(
      "Category selected",
      {
        category
      }
    )

    this.currentCategory =
      category || "ALL"

    this.renderCategories()
    this.renderCatalog()
  }

  renderCatalog() {
    if (!this.hasGridTarget) {
      this.debugCatalog(
        "ERROR: grid target missing"
      )
      return
    }

    const definitions =
      this.filteredCatalog

    this.debugCatalog(
      "Rendering catalog",
      {
        total: this.catalog.length,
        visible: definitions.length,
        category: this.currentCategory,
        search: this.hasSearchTarget
          ? this.searchTarget.value
          : ""
      }
    )

    if (this.hasResultCountTarget) {
      this.resultCountTarget.textContent =
        `${definitions.length} DEFINITION${definitions.length === 1 ? "" : "S"}`
    }

    if (definitions.length === 0) {
      this.gridTarget.innerHTML = ""

      if (this.hasEmptyStateTarget) {
        this.emptyStateTarget.classList.remove(
          "hidden"
        )
        this.emptyStateTarget.classList.add(
          "flex"
        )
      }

      return
    }

    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.add(
        "hidden"
      )
      this.emptyStateTarget.classList.remove(
        "flex"
      )
    }

    this.gridTarget.innerHTML =
      definitions
        .map(
          (definition, index) =>
            this.renderCard(
              definition,
              index
            )
        )
        .join("")
  }

  renderCard(definition, index) {
    const id =
      definition.id ||
      definition.key ||
      `definition-${index}`

    const name =
      definition.name ||
      definition.title ||
      id

    const category =
      definition.category ||
      "GENERAL"

    const fields =
      this.extractFields(definition)

    const required =
      fields.filter(
        (field) => field.required
      ).length

    return `
<button
type="button"
class="group w-full rounded-[26px] border-2 border-slate-100 bg-white p-5 text-left shadow-sm transition-all duration-300 hover:-translate-y-1 hover:border-violet-200 hover:shadow-lg hover:shadow-violet-100/50"
data-definition-id="${this.escapeHtml(String(id))}"
data-action="click->definition-library#selectDefinition"
    >

    <div class="flex items-start justify-between gap-3">

    <div class="flex h-11 w-11 items-center justify-center rounded-2xl border border-violet-100 bg-violet-50 text-lg text-violet-500">
    ${this.escapeHtml(
    definition.icon || "✦"
)}
</div>

<span class="rounded-full border border-violet-100 bg-violet-50 px-2.5 py-1 text-[7px] font-black uppercase tracking-wider text-violet-500">
            ${this.escapeHtml(category)}
          </span>

</div>

<div class="mt-4 text-sm font-black text-slate-700">
    ${this.escapeHtml(name)}
</div>

<div class="mt-1 text-[9px] font-mono text-slate-400">
    ${this.escapeHtml(String(id))}
</div>

<p class="mt-3 line-clamp-3 text-[10px] leading-5 text-slate-400">
    ${this.escapeHtml(
    definition.description || ""
)}
</p>

<div class="mt-5 flex items-center gap-2">

          <span class="rounded-full bg-violet-50 px-2 py-1 text-[7px] font-black uppercase tracking-wider text-violet-500">
            ${fields.length} FIELDS
          </span>

    <span class="rounded-full bg-orange-50 px-2 py-1 text-[7px] font-black uppercase tracking-wider text-orange-500">
            ${required} REQUIRED
          </span>

</div>

</button>
`
  }

  // ============================================================
  // SEARCH
  // ============================================================

  searchChanged(event) {
    const value =
      event?.currentTarget?.value ?? ""

    this.debugSearch(
      "Search changed",
      {
        value
      }
    )

    if (this.hasClearSearchTarget) {
      this.clearSearchTarget.classList.toggle(
        "hidden",
        !value
      )

      this.clearSearchTarget.classList.toggle(
        "flex",
        Boolean(value)
      )
    }

    this.renderCatalog()
  }

  searchKeydown(event) {
    if (event.key === "Escape") {
      event.preventDefault()

      this.debugSearch(
        "Escape pressed in search"
      )

      this.clearSearch()
    }
  }

  clearSearch(event) {
    event?.preventDefault()

    this.debugSearch(
      "Clearing search"
    )

    if (this.hasSearchTarget) {
      this.searchTarget.value = ""
    }

    this.currentCategory = "ALL"

    this.renderCategories()
    this.renderCatalog()
  }

  clearFilters(event) {
    event?.preventDefault()

    this.debugSearch(
      "Resetting all filters"
    )

    this.clearSearch()
  }

  toggleSort(event) {
    event?.preventDefault()

    this.sortMode =
      this.sortMode === "az"
        ? "za"
        : "az"

    this.debugSearch(
      "Sort toggled",
      this.sortMode
    )

    if (this.hasSortButtonTarget) {
      this.sortButtonTarget.textContent =
        this.sortMode === "az"
          ? "A–Z"
          : "Z–A"
    }

    this.renderCatalog()
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  selectDefinition(event) {
    event?.preventDefault()

    const id =
      event?.currentTarget?.dataset
        ?.definitionId

    this.debugPreview(
      "Definition selected",
      {
        id,
        dataset:
          event?.currentTarget?.dataset
      }
    )

    const definition =
      this.catalog.find(
        (item) =>
          String(
            item.id ||
            item.key ||
            ""
          ) === String(id)
      )

    if (!definition) {
      this.debugPreview(
        "ERROR: Definition not found in catalog",
        {
          id,
          catalog: this.catalog
        }
      )

      return
    }

    this.selectedDefinition =
      definition

    this.debugPreview(
      "Selected definition resolved",
      definition
    )

    this.renderPreview(
      definition
    )
  }

  renderPreview(definition) {
    this.debugPreview(
      "Rendering preview",
      definition
    )

    if (this.hasPreviewEmptyTarget) {
      this.previewEmptyTarget.classList.add(
        "hidden"
      )
    }

    if (this.hasPreviewTarget) {
      this.previewTarget.classList.remove(
        "hidden"
      )
      this.previewTarget.classList.add(
        "flex"
      )
    }

    const fields =
      this.extractFields(
        definition
      )

    const required =
      fields.filter(
        (field) => field.required
      ).length

    const active =
      fields.filter(
        (field) =>
          field.active !== false
      ).length

    const id =
      definition.id ||
      definition.key ||
      ""

    const name =
      definition.name ||
      definition.title ||
      id

    if (this.hasPreviewIconTarget) {
      this.previewIconTarget.textContent =
        definition.icon || "✦"
    }

    if (this.hasPreviewTitleTarget) {
      this.previewTitleTarget.textContent =
        name
    }

    if (this.hasPreviewCategoryTarget) {
      this.previewCategoryTarget.textContent =
        definition.category ||
        "GENERAL"
    }

    if (this.hasPreviewIdTarget) {
      this.previewIdTarget.textContent =
        id
    }

    if (this.hasPreviewDescriptionTarget) {
      this.previewDescriptionTarget.textContent =
        definition.description || ""
    }

    if (this.hasPreviewFieldCountTarget) {
      this.previewFieldCountTarget.textContent =
        fields.length
    }

    if (this.hasPreviewRequiredCountTarget) {
      this.previewRequiredCountTarget.textContent =
        required
    }

    if (this.hasPreviewActiveCountTarget) {
      this.previewActiveCountTarget.textContent =
        active
    }

    if (this.hasPreviewFieldSummaryTarget) {
      this.previewFieldSummaryTarget.textContent =
        `${fields.length} fields`
    }

    if (this.hasPreviewJsonTarget) {
      this.previewJsonTarget.textContent =
        JSON.stringify(
          this.normalizeDefinition(
            definition
          ),
          null,
          2
        )
    }

    this.renderPreviewFields(
      fields
    )

    this.showFields()

    this.debugPreview(
      "Preview rendered",
      {
        id,
        fieldCount: fields.length,
        required,
        active
      }
    )
  }

  renderPreviewFields(fields) {
    if (!this.hasFieldListTarget) return

    if (fields.length === 0) {
      this.fieldListTarget.innerHTML = `
<div class="p-5 text-center text-[9px] text-slate-400">
    No fields in this definition.
</div>
`

      return
    }

    this.fieldListTarget.innerHTML =
      fields
        .map(
          (field, index) => `
<div class="flex items-start justify-between gap-3 border-b border-slate-100 bg-white p-4 last:border-b-0">

    <div class="flex min-w-0 items-start gap-3">

    <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-violet-50 text-[8px] font-black text-violet-500">
    ${index + 1}
</div>

<div class="min-w-0">

    <div class="truncate font-mono text-[10px] font-black text-slate-700">
        ${this.escapeHtml(
        field.name
    )}
    </div>

    <div class="mt-1 text-[9px] text-slate-400">
        ${this.escapeHtml(
        field.label ||
        field.name
    )}
    </div>

</div>

</div>

<div class="flex shrink-0 flex-wrap justify-end gap-1">

                <span class="rounded-full bg-violet-50 px-2 py-1 text-[7px] font-black uppercase text-violet-500">
                  ${this.escapeHtml(
                    field.type ||
                    "string"
                )}
                </span>

    ${
    field.required
        ? `
                      <span class="rounded-full bg-orange-50 px-2 py-1 text-[7px] font-black uppercase text-orange-500">
                        REQUIRED
                      </span>
                    `
        : ""
}

</div>

</div>
`
        )
        .join("")
  }

  showFields(event) {
    event?.preventDefault()

    this.debugPreview(
      "Showing Fields tab"
    )

    if (this.hasFieldsPanelTarget) {
      this.fieldsPanelTarget.classList.remove(
        "hidden"
      )
    }

    if (this.hasJsonPanelTarget) {
      this.jsonPanelTarget.classList.add(
        "hidden"
      )
    }

    this.setActiveTab(
      "fields"
    )
  }

  showJson(event) {
    event?.preventDefault()

    this.debugPreview(
      "Showing JSON tab"
    )

    if (this.hasFieldsPanelTarget) {
      this.fieldsPanelTarget.classList.add(
        "hidden"
      )
    }

    if (this.hasJsonPanelTarget) {
      this.jsonPanelTarget.classList.remove(
        "hidden"
      )
    }

    this.setActiveTab(
      "json"
    )
  }

  setActiveTab(tab) {
    if (
      this.hasFieldsTabTarget &&
      this.hasJsonTabTarget
    ) {
      this.fieldsTabTarget.classList.toggle(
        "border-violet-500",
        tab === "fields"
      )

      this.fieldsTabTarget.classList.toggle(
        "text-violet-500",
        tab === "fields"
      )

      this.fieldsTabTarget.classList.toggle(
        "border-transparent",
        tab !== "fields"
      )

      this.fieldsTabTarget.classList.toggle(
        "text-slate-400",
        tab !== "fields"
      )

      this.jsonTabTarget.classList.toggle(
        "border-violet-500",
        tab === "json"
      )

      this.jsonTabTarget.classList.toggle(
        "text-violet-500",
        tab === "json"
      )

      this.jsonTabTarget.classList.toggle(
        "border-transparent",
        tab !== "json"
      )

      this.jsonTabTarget.classList.toggle(
        "text-slate-400",
        tab !== "json"
      )
    }
  }

  showEmptyPreview() {
    if (this.hasPreviewEmptyTarget) {
      this.previewEmptyTarget.classList.remove(
        "hidden"
      )
    }

    if (this.hasPreviewTarget) {
      this.previewTarget.classList.add(
        "hidden"
      )
      this.previewTarget.classList.remove(
        "flex"
      )
    }
  }

  // ============================================================
  // APPLY
  // ============================================================

  apply(event) {
    event?.preventDefault()

    this.debugApply(
      "APPLY action received"
    )

    if (!this.selectedDefinition) {
      this.debugApply(
        "ERROR: No definition selected"
      )

      return
    }

    const definition =
      this.normalizeDefinition(
        this.selectedDefinition
      )

    this.debugApply(
      "Definition being dispatched to builder",
      definition
    )

    const applyEvent =
      new CustomEvent(
        "definition-library:apply",
        {
          bubbles: true,
          detail: {
            definition,
            source: "definition-library",
            id:
              definition.id ||
              definition.key ||
              null
          }
        }
      )

    this.debugApply(
      "Dispatching definition-library:apply",
      {
        event: applyEvent,
        detail: applyEvent.detail
      }
    )

    this.element.dispatchEvent(
      applyEvent
    )

    this.debugApply(
      "Apply event dispatched"
    )

    this.close()

    this.setStatus(
      "IMPORTED"
    )
  }

  // ============================================================
  // COPY
  // ============================================================

  async copyJson(event) {
    event?.preventDefault()

    if (!this.selectedDefinition) {
      this.debugPreview(
        "COPY requested but no definition selected"
      )
      return
    }

    const json =
      JSON.stringify(
        this.normalizeDefinition(
          this.selectedDefinition
        ),
        null,
        2
      )

    this.debugPreview(
      "Copying JSON",
      {
        length: json.length
      }
    )

    try {
      await navigator.clipboard.writeText(
        json
      )

      this.debugPreview(
        "JSON copied successfully"
      )

      this.setStatus(
        "COPIED"
      )
    } catch (error) {
      this.debugPreview(
        "COPY FAILED",
        {
          error,
          message: error.message
        }
      )

      this.setStatus(
        "COPY FAILED"
      )
    }
  }

  // ============================================================
  // STATUS
  // ============================================================

  setStatus(value) {
    if (!this.hasStatusTarget) return

    this.statusTarget.textContent =
      value
  }

  // ============================================================
  // DATA HELPERS
  // ============================================================

  normalizeDefinition(definition) {
    if (
      definition &&
      typeof definition === "object" &&
      definition.definition
    ) {
      return this.normalizeDefinition(
        definition.definition
      )
    }

    if (typeof definition === "string") {
      return JSON.parse(definition)
    }

    return definition
  }

  extractFields(definition) {
    if (!definition) return []

    if (
      Array.isArray(
        definition.fields
      )
    ) {
      return definition.fields
    }

    if (
      definition.fields &&
      typeof definition.fields === "object"
    ) {
      return Object.entries(
        definition.fields
      ).map(
        ([name, field]) => ({
          name,
          ...field
        })
      )
    }

    return []
  }

  escapeHtml(value) {
    return String(value ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#039;")
  }
}