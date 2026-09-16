import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "modal",
    "dialog",
    "backdrop",
    "search",
    "clearSearch",

    "favoritesButton",
    "favoriteCount",
    "recentButton",
    "recentCount",
    "recommendedButton",

    "sortButton",
    "resultCount",
    "activeFilters",

    "advancedFilters",
    "filterType",
    "filterStatus",
    "filterPopularity",
    "filterFeatured",
    "filterNew",
    "clearAllFilters",

    "categories",

    "loadingState",
    "errorState",
    "errorMessage",

    "libraryPanel",
    "recommendations",
    "grid",
    "emptyState",

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
    "fieldList",
    "previewFieldSummary",
    "previewJson",

    "analyticsStatus",
    "applyButton",

    "confirmation",
    "confirmationTitle",
    "confirmationDescription",
    "confirmationCancel",
    "confirmationConfirm",

    "status"
  ]

  static values = {
    catalogUrl: String,
    catalogUsageUrl: String,
    catalog: Array
  }

  connect() {
    this.definitions = []
    this.filteredDefinitions = []

    this.selectedDefinition = null
    this.currentView = "recommended"
    this.currentCategory = "ALL"
    this.currentSort = "popular"

    this.filters = {
      type: "ALL",
      status: "ALL",
      popularity: "ALL",
      featured: "ALL",
      newOnly: false
    }

    this.recentIds = this.loadStorage("definition-library-recent")
    this.favoriteIds = this.loadStorage("definition-library-favorites")

    this.searchTimer = null
    this.lastAppliedDefinition = null

    this.handleOpenEvent = this.handleOpenEvent.bind(this)
    this.handleGlobalKeydown = this.handleGlobalKeydown.bind(this)

    this.element.addEventListener(
        "definition-library:open",
        this.handleOpenEvent
    )

    document.addEventListener(
        "definition-library:open",
        this.handleOpenEvent
    )

    document.addEventListener(
        "keydown",
        this.handleGlobalKeydown
    )

    this.updateFavoriteCount()
    this.updateRecentCount()
    this.setConnectedStatus()

    this.log("connected")
  }

  disconnect() {
    if (this.searchTimer) {
      clearTimeout(this.searchTimer)
    }

    this.element.removeEventListener(
        "definition-library:open",
        this.handleOpenEvent
    )

    document.removeEventListener(
        "definition-library:open",
        this.handleOpenEvent
    )

    document.removeEventListener(
        "keydown",
        this.handleGlobalKeydown
    )

    this.enablePageScroll()
  }

  // ============================================================
  // OPEN / CLOSE
  // ============================================================

  handleOpenEvent(event) {
    this.open(event.detail || {})
  }

  open(options = {}) {
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")

    this.modalTarget.setAttribute("aria-hidden", "false")

    document.body.classList.add("overflow-hidden")

    if (options.definition) {
      this.selectedDefinition = this.normalizeDefinition(options.definition)
      this.renderPreview()
    }

    if (this.definitions.length === 0) {
      this.loadDefinitions()
    } else {
      this.render()
    }

    requestAnimationFrame(() => {
      if (this.hasSearchTarget) {
        this.searchTarget.focus()
      }
    })

    this.log("open")
  }

  close() {
    this.cancelImport()

    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")

    this.modalTarget.setAttribute("aria-hidden", "true")

    document.body.classList.remove("overflow-hidden")

    this.selectedDefinition = null

    if (this.hasPreviewTarget) {
      this.previewTarget.classList.add("hidden")
      this.previewTarget.classList.remove("flex")
    }

    if (this.hasPreviewEmptyTarget) {
      this.previewEmptyTarget.classList.remove("hidden")
    }

    this.log("close")
  }

  handleGlobalKeydown(event) {
    if (
        event.key === "Escape" &&
        this.modalTarget &&
        !this.modalTarget.classList.contains("hidden")
    ) {
      this.close()
    }
  }

  enablePageScroll() {
    document.body.classList.remove("overflow-hidden")
  }

  // ============================================================
  // LOAD
  // ============================================================

  async loadDefinitions() {
    this.showLoading(true)
    this.showError(false)

    try {
      let catalog = []

      if (this.hasCatalogValue && this.catalogValue.length > 0) {
        catalog = this.catalogValue
      } else {
        const response = await fetch(this.catalogUrlValue, {
          method: "GET",
          headers: {
            "Accept": "application/json"
          },
          credentials: "same-origin"
        })

        if (!response.ok) {
          throw new Error(
              `Definition catalog request failed: ${response.status}`
          )
        }

        const payload = await response.json()

        catalog = this.extractDefinitions(payload)
      }

      this.definitions = catalog
          .map((definition) => this.normalizeDefinition(definition))
          .filter(Boolean)

      this.log("definitions-loaded", {
        count: this.definitions.length
      })

      this.render()
    } catch (error) {
      console.error(
          "[DefinitionLibrary] Failed to load definitions",
          error
      )

      this.showError(
          true,
          "Unable to load definitions. Please try again."
      )
    } finally {
      this.showLoading(false)
    }
  }

  extractDefinitions(payload) {
    if (Array.isArray(payload)) {
      return payload
    }

    if (!payload || typeof payload !== "object") {
      return []
    }

    const possibleKeys = [
      "definitions",
      "definition_templates",
      "definitionTemplates",
      "items",
      "results",
      "data"
    ]

    for (const key of possibleKeys) {
      if (Array.isArray(payload[key])) {
        return payload[key]
      }
    }

    return []
  }

  // ============================================================
  // NORMALIZATION
  // ============================================================

  normalizeDefinition(raw) {
    if (!raw || typeof raw !== "object") {
      return null
    }

    const source =
        raw.definition ||
        raw.template ||
        raw.data ||
        raw

    const fields = this.extractFields(source)

    const id =
        source.id ??
        raw.id ??
        source.definition_id ??
        raw.definition_id

    const name =
        source.name ||
        source.title ||
        source.label ||
        source.slug ||
        `Definition ${id ?? ""}`.trim()

    const normalized = {
      ...source,

      id: id != null ? String(id) : null,

      slug:
          source.slug ||
          raw.slug ||
          this.slugify(name),

      name,

      title:
          source.title ||
          name,

      category:
          source.category ||
          source.type ||
          raw.category ||
          "GENERAL",

      description:
          source.description ||
          source.summary ||
          raw.description ||
          "",

      icon:
          source.icon ||
          source.emoji ||
          raw.icon ||
          "✦",

      version:
          source.version ||
          raw.version ||
          1,

      status:
          source.status ||
          raw.status ||
          "ACTIVE",

      featured:
          Boolean(
              source.featured ??
              source.is_featured ??
              raw.featured ??
              false
          ),

      isNew:
          Boolean(
              source.new ??
              source.is_new ??
              raw.new ??
              false
          ),

      popularity:
          Number(
              source.popularity ??
              source.popularity_score ??
              raw.popularity ??
              0
          ),

      usageCount:
          Number(
              source.usage_count ??
              source.usageCount ??
              raw.usage_count ??
              0
          ),

      tags:
          this.extractTags(source),

      fields
    }

    normalized.field_count = fields.length

    return normalized
  }

  extractFields(definition) {
    if (!definition || typeof definition !== "object") {
      return []
    }

    const candidates = [
      definition.fields,
      definition.field_definitions,
      definition.fieldDefinitions,
      definition.properties,
      definition.schema?.fields,
      definition.schema?.properties,
      definition.definition?.fields,
      definition.template?.fields,
      definition.structure?.fields,
      definition.structure?.properties,
      definition.config?.fields,
      definition.config?.properties
    ]

    for (const candidate of candidates) {
      const fields = this.normalizeFieldsCandidate(candidate)

      if (fields.length > 0) {
        return fields
      }

      if (Array.isArray(candidate) && candidate.length === 0) {
        return []
      }
    }

    /*
     * Some APIs return the JSON structure itself as a string.
     */
    const jsonCandidates = [
      definition.json,
      definition.definition_json,
      definition.schema_json,
      definition.structure_json
    ]

    for (const value of jsonCandidates) {
      if (!value) continue

      try {
        const parsed =
            typeof value === "string"
                ? JSON.parse(value)
                : value

        const fields = this.extractFields(parsed)

        if (fields.length > 0) {
          return fields
        }
      } catch (_error) {
        // Ignore malformed optional JSON.
      }
    }

    return []
  }

  normalizeFieldsCandidate(candidate) {
    if (!candidate) {
      return []
    }

    if (Array.isArray(candidate)) {
      return candidate
          .map((field, index) => this.normalizeField(field, index))
          .filter(Boolean)
    }

    if (typeof candidate === "object") {
      return Object.entries(candidate)
          .map(([key, value], index) => {
            if (
                value &&
                typeof value === "object" &&
                !Array.isArray(value)
            ) {
              return this.normalizeField(
                  {
                    ...value,
                    name:
                        value.name ||
                        value.key ||
                        value.slug ||
                        key
                  },
                  index
              )
            }

            return this.normalizeField(
                {
                  name: key,
                  type: this.inferFieldType(value),
                  default: value
                },
                index
            )
          })
          .filter(Boolean)
    }

    return []
  }

  normalizeField(raw, index = 0) {
    if (!raw) {
      return null
    }

    if (typeof raw === "string") {
      return {
        name: raw,
        label: this.humanize(raw),
        type: "string",
        required: false,
        active: true
      }
    }

    const name =
        raw.name ||
        raw.key ||
        raw.slug ||
        raw.field ||
        `field_${index + 1}`

    return {
      ...raw,

      id:
          raw.id ??
          raw.field_id ??
          `${name}-${index}`,

      name: String(name),

      label:
          raw.label ||
          raw.title ||
          this.humanize(name),

      type:
          raw.type ||
          raw.field_type ||
          raw.data_type ||
          "string",

      required: Boolean(
          raw.required ??
          raw.is_required ??
          false
      ),

      active:
          raw.active === undefined
              ? raw.status
                  ? String(raw.status).toUpperCase() === "ACTIVE"
                  : true
              : Boolean(raw.active),

      description:
          raw.description ||
          raw.help_text ||
          raw.helpText ||
          ""
    }
  }

  inferFieldType(value) {
    if (typeof value === "boolean") return "boolean"
    if (typeof value === "number") return "number"
    if (Array.isArray(value)) return "array"
    if (value && typeof value === "object") return "json"

    return "string"
  }

  extractTags(definition) {
    const tags =
        definition.tags ||
        definition.keywords ||
        []

    if (Array.isArray(tags)) {
      return tags
          .map((tag) => String(tag))
          .filter(Boolean)
    }

    if (typeof tags === "string") {
      return tags
          .split(",")
          .map((tag) => tag.trim())
          .filter(Boolean)
    }

    return []
  }

  // ============================================================
  // SEARCH / FILTERS
  // ============================================================

  searchChanged() {
    if (this.searchTimer) {
      clearTimeout(this.searchTimer)
    }

    this.searchTimer = setTimeout(() => {
      this.render()
    }, 120)
  }

  searchKeydown(event) {
    if (event.key === "Escape") {
      event.stopPropagation()
      this.clearSearch()
    }
  }

  clearSearch() {
    this.searchTarget.value = ""
    this.render()
    this.searchTarget.focus()
  }

  showFavorites() {
    this.currentView = "favorites"
    this.render()
  }

  showRecent() {
    this.currentView = "recent"
    this.render()
  }

  showRecommended() {
    this.currentView = "recommended"
    this.render()
  }

  showAll() {
    this.currentView = "all"
    this.render()
  }

  toggleAdvancedFilters() {
    this.advancedFiltersTarget.classList.toggle("hidden")
  }

  advancedFilterChanged() {
    this.filters = {
      type: this.filterTypeTarget.value,
      status: this.filterStatusTarget.value,
      popularity: this.filterPopularityTarget.value,
      featured: this.filterFeaturedTarget.value,
      newOnly: this.filterNewTarget.checked
    }

    this.render()
  }

  clearFilters() {
    if (this.hasSearchTarget) {
      this.searchTarget.value = ""
    }

    this.currentView = "all"
    this.currentCategory = "ALL"

    this.filterTypeTarget.value = "ALL"
    this.filterStatusTarget.value = "ALL"
    this.filterPopularityTarget.value = "ALL"
    this.filterFeaturedTarget.value = "ALL"
    this.filterNewTarget.checked = false

    this.filters = {
      type: "ALL",
      status: "ALL",
      popularity: "ALL",
      featured: "ALL",
      newOnly: false
    }

    this.render()
  }

  toggleSort() {
    const order = [
      "popular",
      "recent",
      "name"
    ]

    const index = order.indexOf(this.currentSort)

    this.currentSort =
        order[(index + 1) % order.length]

    this.sortButtonTarget.textContent =
        this.currentSort === "popular"
            ? "POPULAR"
            : this.currentSort === "recent"
                ? "RECENT"
                : "NAME"

    this.render()
  }

  selectCategory(category) {
    this.currentCategory = category
    this.render()
  }

  getFilteredDefinitions() {
    const search =
        this.hasSearchTarget
            ? this.searchTarget.value.trim().toLowerCase()
            : ""

    let results = [...this.definitions]

    if (search) {
      results = results.filter((definition) => {
        const haystack = [
          definition.name,
          definition.title,
          definition.slug,
          definition.category,
          definition.description,
          ...(definition.tags || []),
          ...(definition.fields || []).map(
              (field) =>
                  `${field.name} ${field.label} ${field.type}`
          )
        ]
            .join(" ")
            .toLowerCase()

        return haystack.includes(search)
      })
    }

    if (this.currentCategory !== "ALL") {
      results = results.filter(
          (definition) =>
              String(definition.category).toUpperCase() ===
              String(this.currentCategory).toUpperCase()
      )
    }

    if (this.currentView === "favorites") {
      results = results.filter((definition) =>
          this.favoriteIds.includes(String(definition.id))
      )
    }

    if (this.currentView === "recent") {
      results = results.filter((definition) =>
          this.recentIds.includes(String(definition.id))
      )
    }

    if (this.currentView === "recommended") {
      results = results
          .filter((definition) => {
            return (
                definition.featured ||
                Number(definition.popularity) >= 50
            )
          })
    }

    if (this.filters.type !== "ALL") {
      results = results.filter((definition) =>
          definition.fields.some(
              (field) =>
                  String(field.type).toLowerCase() ===
                  this.filters.type.toLowerCase()
          )
      )
    }

    if (this.filters.status !== "ALL") {
      results = results.filter(
          (definition) =>
              String(definition.status).toUpperCase() ===
              this.filters.status
      )
    }

    if (this.filters.popularity !== "ALL") {
      results = results.filter((definition) => {
        const score = Number(definition.popularity || 0)

        if (this.filters.popularity === "HIGH") {
          return score >= 80
        }

        if (this.filters.popularity === "MEDIUM") {
          return score >= 40 && score < 80
        }

        return score < 40
      })
    }

    if (this.filters.featured !== "ALL") {
      const expected =
          this.filters.featured === "YES"

      results = results.filter(
          (definition) =>
              definition.featured === expected
      )
    }

    if (this.filters.newOnly) {
      results = results.filter(
          (definition) => definition.isNew
      )
    }

    if (this.currentSort === "name") {
      results.sort((a, b) =>
          String(a.name).localeCompare(String(b.name))
      )
    } else if (this.currentSort === "recent") {
      results.sort(
          (a, b) =>
              Number(b.updated_at_timestamp || 0) -
              Number(a.updated_at_timestamp || 0)
      )
    } else {
      results.sort(
          (a, b) =>
              Number(b.popularity || 0) -
              Number(a.popularity || 0)
      )
    }

    return results
  }

  // ============================================================
  // RENDER
  // ============================================================

  render() {
    this.renderCategories()

    const results = this.getFilteredDefinitions()

    this.filteredDefinitions = results

    this.resultCountTarget.textContent =
        `${results.length} ${
            results.length === 1
                ? "DEFINITION"
                : "DEFINITIONS"
        }`

    this.renderGrid(results)
    this.renderRecommendations(results)
    this.renderActiveFilters()
    this.updateFavoriteCount()
    this.updateRecentCount()

    if (results.length === 0) {
      this.emptyStateTarget.classList.remove("hidden")
      this.emptyStateTarget.classList.add("flex")
    } else {
      this.emptyStateTarget.classList.add("hidden")
      this.emptyStateTarget.classList.remove("flex")
    }
  }

  renderCategories() {
    const categories = [
      "ALL",
      ...new Set(
          this.definitions
              .map((definition) =>
                  String(definition.category || "GENERAL")
              )
              .filter(Boolean)
      )
    ]

    this.categoriesTarget.innerHTML =
        categories
            .map((category) => {
              const active =
                  category === this.currentCategory

              return `
            <button
              type="button"
              class="
                shrink-0 rounded-full border-2 px-4 py-2
                text-xs font-bold uppercase tracking-wide
                transition
                ${
                  active
                      ? "border-violet-300 bg-violet-100 text-violet-700"
                      : "border-slate-200 bg-white text-slate-500 hover:border-violet-200 hover:bg-violet-50 hover:text-violet-600"
              }
              "
              data-category="${this.escapeHtml(category)}"
              data-action="click->definition-library#categoryClicked"
            >
              ${this.escapeHtml(category)}
            </button>
          `
            })
            .join("")
  }

  categoryClicked(event) {
    this.selectCategory(
        event.currentTarget.dataset.category
    )
  }

  renderGrid(definitions) {
    this.gridTarget.innerHTML = definitions
        .map((definition) =>
            this.definitionCard(definition)
        )
        .join("")
  }

  definitionCard(definition) {
    const id = String(definition.id)

    const favorite =
        this.favoriteIds.includes(id)

    const fields = definition.fields || []

    return `
      <article
        class="
          group relative flex flex-col overflow-hidden
          rounded-3xl border-2 border-slate-200
          bg-white shadow-sm
          transition duration-200
          hover:-translate-y-0.5
          hover:border-violet-200
          hover:shadow-xl hover:shadow-violet-100/60
        "
      >

        <button
          type="button"
          class="
            absolute right-4 top-4 z-10
            flex h-9 w-9 items-center justify-center
            rounded-xl border
            ${
        favorite
            ? "border-amber-200 bg-amber-50 text-amber-500"
            : "border-slate-200 bg-white text-slate-300 hover:text-amber-500"
    }
          "
          title="${favorite ? "Remove favorite" : "Add favorite"}"
          data-definition-id="${this.escapeHtml(id)}"
          data-action="click->definition-library#toggleFavorite"
        >
          ★
        </button>

        <button
          type="button"
          class="flex flex-1 flex-col text-left"
          data-definition-id="${this.escapeHtml(id)}"
          data-action="click->definition-library#selectDefinition"
        >

          <div class="border-b border-slate-100 bg-gradient-to-br from-violet-50 via-white to-sky-50 p-5">

            <div class="flex items-start gap-4 pr-10">

              <div
                class="
                  flex h-12 w-12 shrink-0
                  items-center justify-center
                  rounded-2xl border-2 border-violet-100
                  bg-white text-xl text-violet-500
                  shadow-sm
                "
              >
                ${this.escapeHtml(definition.icon)}
              </div>

              <div class="min-w-0">

                <div class="truncate text-base font-extrabold text-slate-800">
                  ${this.escapeHtml(definition.title)}
                </div>

                <div class="mt-2 flex flex-wrap gap-2">

                  <span class="rounded-full border border-violet-200 bg-violet-100 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wide text-violet-700">
                    ${this.escapeHtml(definition.category)}
                  </span>

                  ${
        definition.featured
            ? `
                        <span class="rounded-full border border-amber-200 bg-amber-50 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wide text-amber-600">
                          FEATURED
                        </span>
                      `
            : ""
    }

                </div>

              </div>

            </div>

          </div>

          <div class="flex flex-1 flex-col p-5">

            <p class="line-clamp-3 text-sm leading-6 text-slate-500">
              ${this.escapeHtml(
        definition.description ||
        "Production-ready entity definition."
    )}
            </p>

            <div class="mt-5 grid grid-cols-2 gap-3">

              <div class="rounded-2xl border border-violet-100 bg-violet-50/60 p-3">
                <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">
                  FIELDS
                </div>
                <div class="mt-1 text-xl font-extrabold text-violet-600">
                  ${fields.length}
                </div>
              </div>

              <div class="rounded-2xl border border-emerald-100 bg-emerald-50/60 p-3">
                <div class="text-[10px] font-bold uppercase tracking-wide text-slate-400">
                  ACTIVE
                </div>
                <div class="mt-1 text-xl font-extrabold text-emerald-600">
                  ${
        fields.filter(
            (field) => field.active
        ).length
    }
                </div>
              </div>

            </div>

            <div class="mt-5 flex items-center justify-between">

              <span class="text-xs font-semibold text-slate-400">
                v${this.escapeHtml(
        String(definition.version || 1)
    )}
              </span>

              <span class="text-xs font-bold text-violet-600">
                VIEW STRUCTURE →
              </span>

            </div>

          </div>

        </button>

      </article>
    `
  }

  renderRecommendations(results) {
    if (
        this.currentView !== "recommended" ||
        results.length === 0
    ) {
      this.recommendationsTarget.innerHTML = ""
      return
    }

    this.recommendationsTarget.innerHTML = `
      <div class="rounded-2xl border-2 border-violet-100 bg-violet-50/60 px-5 py-4">

        <div class="flex items-start gap-3">

          <div class="mt-0.5 text-lg text-violet-500">
            ✦
          </div>

          <div>
            <div class="text-sm font-extrabold text-violet-800">
              Recommended definitions
            </div>

            <p class="mt-1 text-xs leading-5 text-violet-600/80">
              These structures are surfaced from featured and commonly used definitions.
            </p>
          </div>

        </div>

      </div>
    `
  }

  renderActiveFilters() {
    const active = []

    if (this.currentCategory !== "ALL") {
      active.push(this.currentCategory)
    }

    if (this.filters.type !== "ALL") {
      active.push(this.filters.type)
    }

    if (this.filters.status !== "ALL") {
      active.push(this.filters.status)
    }

    if (this.filters.popularity !== "ALL") {
      active.push(this.filters.popularity)
    }

    if (this.filters.featured !== "ALL") {
      active.push(
          this.filters.featured === "YES"
              ? "FEATURED"
              : "NOT FEATURED"
      )
    }

    if (this.filters.newOnly) {
      active.push("NEW")
    }

    if (active.length === 0) {
      this.activeFiltersTarget.innerHTML = ""
      return
    }

    this.activeFiltersTarget.innerHTML = `
      <div class="flex flex-wrap items-center gap-2">

        ${active
        .map(
            (filter) => `
              <span class="rounded-full border border-violet-200 bg-violet-50 px-3 py-1.5 text-[10px] font-bold text-violet-600">
                ${this.escapeHtml(filter)}
              </span>
            `
        )
        .join("")}

        <button
          type="button"
          class="text-xs font-bold text-slate-400 underline hover:text-slate-600"
          data-action="click->definition-library#clearFilters"
        >
          Clear
        </button>

      </div>
    `
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  selectDefinition(event) {
    const id =
        event.currentTarget.dataset.definitionId

    const definition =
        this.definitions.find(
            (item) => String(item.id) === String(id)
        )

    if (!definition) return

    this.selectedDefinition = definition

    this.rememberRecent(id)
    this.renderPreview()
  }

  renderPreview() {
    const definition = this.selectedDefinition

    if (!definition) {
      this.previewTarget.classList.add("hidden")
      this.previewEmptyTarget.classList.remove("hidden")
      return
    }

    this.previewEmptyTarget.classList.add("hidden")

    this.previewTarget.classList.remove("hidden")
    this.previewTarget.classList.add("flex")

    const fields = definition.fields || []

    this.previewIconTarget.textContent =
        definition.icon || "✦"

    this.previewTitleTarget.textContent =
        definition.title || definition.name

    this.previewCategoryTarget.textContent =
        definition.category || "GENERAL"

    this.previewIdTarget.textContent =
        `ID ${definition.id ?? "—"}`

    this.previewDescriptionTarget.textContent =
        definition.description ||
        "Production-ready entity definition."

    this.previewFieldCountTarget.textContent =
        fields.length

    this.previewRequiredCountTarget.textContent =
        fields.filter(
            (field) => field.required
        ).length

    this.previewActiveCountTarget.textContent =
        fields.filter(
            (field) => field.active
        ).length

    this.previewFieldSummaryTarget.textContent =
        `${fields.length} ${
            fields.length === 1
                ? "field"
                : "fields"
        }`

    this.fieldListTarget.innerHTML =
        fields.length > 0
            ? fields
                .map(
                    (field, index) =>
                        this.fieldRow(field, index)
                )
                .join("")
            : `
          <div class="p-8 text-center">

            <div class="text-sm font-bold text-slate-500">
              No fields found
            </div>

            <p class="mt-2 text-xs leading-5 text-slate-400">
              This definition does not currently contain any field definitions.
            </p>

          </div>
        `

    const json = this.definitionToJson(
        definition
    )

    this.previewJsonTarget.textContent =
        JSON.stringify(json, null, 2)

    this.analyticsStatusTarget.textContent =
        `${fields.length} ${
            fields.length === 1
                ? "field"
                : "fields"
        } ready to import into Definition Studio.`

    this.applyButtonTarget.disabled = false

    this.showFields()
  }

  fieldRow(field, index) {
    const type = String(
        field.type || "string"
    ).toUpperCase()

    return `
      <div
        class="
          border-b border-slate-100
          bg-white px-4 py-4
          last:border-b-0
        "
      >

        <div class="flex items-start gap-4">

          <div
            class="
              flex h-9 w-9 shrink-0
              items-center justify-center
              rounded-xl bg-violet-50
              text-xs font-extrabold
              text-violet-600
            "
          >
            ${index + 1}
          </div>

          <div class="min-w-0 flex-1">

            <div class="flex flex-wrap items-center gap-2">

              <span class="break-words text-sm font-extrabold text-slate-800">
                ${this.escapeHtml(field.label || field.name)}
              </span>

              <span class="rounded-full border border-sky-200 bg-sky-50 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wide text-sky-700">
                ${this.escapeHtml(type)}
              </span>

              ${
        field.required
            ? `
                    <span class="rounded-full border border-orange-200 bg-orange-50 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wide text-orange-700">
                      REQUIRED
                    </span>
                  `
            : ""
    }

              ${
        field.active
            ? `
                    <span class="rounded-full border border-emerald-200 bg-emerald-50 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wide text-emerald-700">
                      ACTIVE
                    </span>
                  `
            : `
                    <span class="rounded-full border border-slate-200 bg-slate-100 px-2.5 py-1 text-[10px] font-bold uppercase tracking-wide text-slate-500">
                      INACTIVE
                    </span>
                  `
    }

            </div>

            <div class="mt-1 break-all font-mono text-xs text-slate-400">
              ${this.escapeHtml(field.name)}
            </div>

            ${
        field.description
            ? `
                  <p class="mt-2 text-xs leading-5 text-slate-500">
                    ${this.escapeHtml(
                field.description
            )}
                  </p>
                `
            : ""
    }

          </div>

        </div>

      </div>
    `
  }

  showFields() {
    this.fieldsPanelTarget.classList.remove("hidden")
    this.jsonPanelTarget.classList.add("hidden")

    this.fieldsTabTarget.classList.add(
        "border-violet-500",
        "text-violet-600"
    )

    this.fieldsTabTarget.classList.remove(
        "border-transparent",
        "text-slate-400"
    )

    this.fieldsTabTarget.setAttribute(
        "aria-selected",
        "true"
    )

    this.jsonTabTarget.classList.remove(
        "border-violet-500",
        "text-violet-600"
    )

    this.jsonTabTarget.classList.add(
        "border-transparent",
        "text-slate-400"
    )

    this.jsonTabTarget.setAttribute(
        "aria-selected",
        "false"
    )
  }

  showJson() {
    this.fieldsPanelTarget.classList.add("hidden")
    this.jsonPanelTarget.classList.remove("hidden")

    this.jsonTabTarget.classList.add(
        "border-violet-500",
        "text-violet-600"
    )

    this.jsonTabTarget.classList.remove(
        "border-transparent",
        "text-slate-400"
    )

    this.jsonTabTarget.setAttribute(
        "aria-selected",
        "true"
    )

    this.fieldsTabTarget.classList.remove(
        "border-violet-500",
        "text-violet-600"
    )

    this.fieldsTabTarget.classList.add(
        "border-transparent",
        "text-slate-400"
    )

    this.fieldsTabTarget.setAttribute(
        "aria-selected",
        "false"
    )
  }

  definitionToJson(definition) {
    const result = {
      id: definition.id,
      slug: definition.slug,
      name: definition.name,
      title: definition.title,
      category: definition.category,
      version: definition.version,
      fields: definition.fields || []
    }

    return result
  }

  // ============================================================
  // APPLY
  // ============================================================

  apply() {
    if (!this.selectedDefinition) {
      return
    }

    const definition =
        this.normalizeDefinition(
            this.selectedDefinition
        )

    const payload = {
      definition,
      definition_id: String(
          definition.id
      ),
      version:
          definition.version || 1,
      source: "definition_library"
    }

    this.lastAppliedDefinition = definition

    this.log("apply:start", {
      id: definition.id,
      fields: definition.fields?.length || 0
    })

    /*
     * IMPORTANT:
     *
     * Dispatch first so the existing Entity Builder receives
     * exactly the event it already listens for.
     */
    const event =
        new CustomEvent(
            "definition-library:apply",
            {
              bubbles: true,
              detail: payload
            }
        )

    document.dispatchEvent(event)

    /*
     * Also dispatch on the application element for integrations
     * that listen there.
     */
    if (this.element !== document) {
      this.element.dispatchEvent(
          new CustomEvent(
              "definition-library:applied",
              {
                bubbles: true,
                detail: payload
              }
          )
      )
    }

    this.log("apply:events-dispatched", {
      id: definition.id,
      fields: definition.fields?.length || 0
    })

    /*
     * CLOSE IMMEDIATELY.
     *
     * Usage tracking must never block importing.
     */
    this.close()

    /*
     * Usage analytics is deliberately fire-and-forget.
     * If the endpoint is unavailable, the definition has
     * already been successfully applied and the modal is closed.
     */
    this.trackUsage(definition).catch((error) => {
      console.warn(
          "[DefinitionLibrary] Usage tracking failed",
          error
      )
    })
  }

  // ============================================================
  // USAGE TRACKING
  // ============================================================

  async trackUsage(definition) {
    if (!this.catalogUsageUrlValue) {
      return
    }

    const url =
        this.catalogUsageUrlValue.replace(
            ":id",
            encodeURIComponent(
                String(definition.id)
            )
        )

    try {
      const response = await fetch(url, {
        method: "POST",

        credentials: "same-origin",

        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token":
              this.csrfToken()
        },

        body: JSON.stringify({
          definition_id: definition.id,
          version: definition.version || 1,
          source: "definition_library"
        })
      })

      if (!response.ok) {
        throw new Error(
            `Usage tracking failed: ${response.status}`
        )
      }

      this.log("usage-tracked", {
        id: definition.id
      })
    } catch (error) {
      /*
       * Do not throw this into the apply flow.
       * Tracking is optional analytics.
       */
      console.warn(
          "[DefinitionLibrary] Usage tracking unavailable",
          error
      )
    }
  }

  csrfToken() {
    const meta =
        document.querySelector(
            'meta[name="csrf-token"]'
        )

    return meta
        ? meta.content
        : ""
  }

  // ============================================================
  // FAVORITES / RECENT
  // ============================================================

  toggleFavorite(event) {
    event.stopPropagation()

    const id =
        String(
            event.currentTarget.dataset.definitionId
        )

    if (this.favoriteIds.includes(id)) {
      this.favoriteIds =
          this.favoriteIds.filter(
              (item) => item !== id
          )
    } else {
      this.favoriteIds.push(id)
    }

    this.saveStorage(
        "definition-library-favorites",
        this.favoriteIds
    )

    this.updateFavoriteCount()
    this.render()
  }

  rememberRecent(id) {
    id = String(id)

    this.recentIds =
        [
          id,
          ...this.recentIds.filter(
              (item) => item !== id
          )
        ].slice(0, 20)

    this.saveStorage(
        "definition-library-recent",
        this.recentIds
    )

    this.updateRecentCount()
  }

  updateFavoriteCount() {
    if (this.hasFavoriteCountTarget) {
      this.favoriteCountTarget.textContent =
          this.favoriteIds.length
    }
  }

  updateRecentCount() {
    if (this.hasRecentCountTarget) {
      this.recentCountTarget.textContent =
          this.recentIds.length
    }
  }

  // ============================================================
  // CONFIRMATION
  // ============================================================

  cancelImport() {
    if (!this.hasConfirmationTarget) {
      return
    }

    this.confirmationTarget.classList.add("hidden")
    this.confirmationTarget.classList.remove("flex")
    this.confirmationTarget.setAttribute(
        "aria-hidden",
        "true"
    )
  }

  // Kept for compatibility with existing markup.
  confirmImport() {
    this.cancelImport()
    this.apply()
  }

  // ============================================================
  // UI STATE
  // ============================================================

  showLoading(show) {
    if (!this.hasLoadingStateTarget) return

    this.loadingStateTarget.classList.toggle(
        "hidden",
        !show
    )
  }

  showError(show, message = null) {
    if (!this.hasErrorStateTarget) return

    this.errorStateTarget.classList.toggle(
        "hidden",
        !show
    )

    if (
        show &&
        message &&
        this.hasErrorMessageTarget
    ) {
      this.errorMessageTarget.textContent =
          message
    }
  }

  setConnectedStatus() {
    if (!this.hasStatusTarget) return

    this.statusTarget.textContent =
        "CONNECTED"
  }

  // ============================================================
  // STORAGE
  // ============================================================

  loadStorage(key) {
    try {
      const value =
          window.localStorage.getItem(key)

      if (!value) {
        return []
      }

      const parsed = JSON.parse(value)

      return Array.isArray(parsed)
          ? parsed.map(String)
          : []
    } catch (_error) {
      return []
    }
  }

  saveStorage(key, value) {
    try {
      window.localStorage.setItem(
          key,
          JSON.stringify(value)
      )
    } catch (_error) {
      // Storage is optional.
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  slugify(value) {
    return String(value || "")
        .toLowerCase()
        .trim()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-+|-+$/g, "")
  }

  humanize(value) {
    return String(value || "")
        .replace(/[_-]+/g, " ")
        .replace(/\s+/g, " ")
        .trim()
        .replace(/\b\w/g, (letter) =>
            letter.toUpperCase()
        )
  }

  escapeHtml(value) {
    return String(value ?? "")
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;")
  }

  log(message, data = null) {
    if (data) {
      console.debug(
          `[DefinitionLibrary] ${message}`,
          data
      )
    } else {
      console.debug(
          `[DefinitionLibrary] ${message}`
      )
    }
  }

  copyJson() {
    if (!this.hasPreviewJsonTarget) {
      return
    }

    const value =
        this.previewJsonTarget.textContent || ""

    if (!navigator.clipboard) {
      return
    }

    navigator.clipboard
        .writeText(value)
        .then(() => {
          this.analyticsStatusTarget.textContent =
              "JSON copied to clipboard."
        })
        .catch(() => {
          this.analyticsStatusTarget.textContent =
              "Unable to copy JSON."
        })
  }
}