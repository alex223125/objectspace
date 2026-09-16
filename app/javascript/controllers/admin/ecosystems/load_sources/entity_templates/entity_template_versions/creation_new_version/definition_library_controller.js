import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "modal",
    "dialog",
    "backdrop",
    "status",

    "search",
    "clearSearch",
    "sortButton",
    "resultCount",
    "categories",
    "grid",
    "emptyState",
    "libraryPanel",

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
    "previewFieldSummary",
    "fieldList",

    "fieldsTab",
    "jsonTab",
    "fieldsPanel",
    "jsonPanel",
    "previewJson",

    "applyButton"
  ]

  static values = {
    catalog: {
      type: Array,
      default: []
    },

    catalogUrl: String,

    catalogUsageUrl: String,

    debug: {
      type: Boolean,
      default: true
    },

    autoLoad: {
      type: Boolean,
      default: true
    }
  }

  connect() {
    this.debugLog("connect:start")

    this.catalog = []
    this.filteredCatalog = []

    this.selectedDefinition = null

    this.searchQuery = ""
    this.selectedCategory = "ALL"
    this.sortMode = "az"
    this.activeTab = "fields"

    this.loading = false
    this.error = null

    this.favorites = this.loadFavorites()
    this.recentlyViewed = this.loadRecentlyViewed()

    this.sessionIdValue = this.getOrCreateSessionId()

    /*
     * ------------------------------------------------------------
     * INITIAL CATALOG
     * ------------------------------------------------------------
     */

    if (this.hasCatalogUrlValue && this.catalogUrlValue) {
      this.debugLog("connect:api-mode", {
        catalogUrl: this.catalogUrlValue
      })

      if (this.autoLoadValue) {
        this.loadCatalog()
      }
    } else {
      this.debugLog("connect:inline-catalog-mode", {
        count: this.catalogValue.length
      })

      this.catalog = this.normalizeCatalog(
          Array.isArray(this.catalogValue)
              ? this.catalogValue
              : []
      )

      this.render()
    }

    /*
     * ------------------------------------------------------------
     * GLOBAL KEYBOARD HANDLER
     * ------------------------------------------------------------
     */

    this.boundKeydown =
        this.handleGlobalKeydown.bind(this)

    document.addEventListener(
        "keydown",
        this.boundKeydown
    )

    /*
     * ------------------------------------------------------------
     * OPEN EVENT
     * ------------------------------------------------------------
     */

    this.boundOpen =
        this.handleOpenEvent.bind(this)

    this.element.addEventListener(
        "definition-library:open",
        this.boundOpen
    )

    this.debugLog("connect:complete", {
      catalogCount: this.catalog.length,
      favoritesCount: this.favorites.length,
      recentCount: this.recentlyViewed.length
    })
  }

  disconnect() {
    this.debugLog("disconnect")

    document.removeEventListener(
        "keydown",
        this.boundKeydown
    )

    this.element.removeEventListener(
        "definition-library:open",
        this.boundOpen
    )
  }

  /*
   * ============================================================
   * DEBUG
   * ============================================================
   */

  debugLog(event, data = {}) {
    if (!this.debugValue) {
      return
    }

    console.groupCollapsed(
        `%c[DefinitionLibrary] ${event}`,
        "color:#8b5cf6;font-weight:bold;"
    )

    console.log({
      timestamp: new Date().toISOString(),
      event,
      ...data
    })

    console.groupEnd()
  }

  debugError(event, error, data = {}) {
    console.groupCollapsed(
        `%c[DefinitionLibrary ERROR] ${event}`,
        "color:#ef4444;font-weight:bold;"
    )

    console.error(error)

    console.log({
      timestamp: new Date().toISOString(),
      event,
      ...data
    })

    console.groupEnd()
  }

  debug(event, data = {}) {
    this.debugLog(event, data)
  }

  /*
   * ============================================================
   * MODAL
   * ============================================================
   */

  open(event = null) {
    if (event) {
      event.preventDefault?.()
    }

    this.debugLog("open:start", {
      eventType: event?.type,
      catalogCount: this.catalog.length
    })

    if (!this.hasModalTarget) {
      this.debugError(
          "open:no-modal-target",
          new Error("Modal target is missing")
      )

      return
    }

    this.modalTarget.classList.remove("hidden")
    this.modalTarget.setAttribute(
        "aria-hidden",
        "false"
    )

    document.body.classList.add(
        "overflow-hidden"
    )

    this.setStatus("CONNECTED")

    /*
     * Re-render when opening.
     *
     * This is useful if the catalog was loaded asynchronously
     * before the modal was opened.
     */

    this.render()

    this.focusSearch()

    this.debugLog("open:complete", {
      catalogCount: this.catalog.length,
      filteredCount: this.filteredCatalog.length
    })
  }

  close(event = null) {
    if (event) {
      event.preventDefault()
    }

    this.debugLog("close:start")

    if (!this.hasModalTarget) {
      return
    }

    this.modalTarget.classList.add("hidden")

    this.modalTarget.setAttribute(
        "aria-hidden",
        "true"
    )

    document.body.classList.remove(
        "overflow-hidden"
    )

    this.debugLog("close:complete")
  }

  handleOpenEvent(event) {
    this.debugLog(
        "event:definition-library:open",
        {
          detail: event.detail
        }
    )

    this.open(event)
  }

  /*
   * ============================================================
   * API CATALOG
   * ============================================================
   */

  async loadCatalog() {
    this.debugLog("loadCatalog:start", {
      url: this.catalogUrlValue
    })

    this.error = null

    this.setLoadingState(true)

    try {
      if (
          !this.hasCatalogUrlValue ||
          !this.catalogUrlValue
      ) {
        throw new Error(
            "Definition catalog URL is missing."
        )
      }

      const response = await fetch(
          this.catalogUrlValue,
          {
            method: "GET",
            headers: {
              Accept: "application/json"
            },
            credentials: "same-origin"
          }
      )

      this.debugLog(
          "loadCatalog:response",
          {
            status: response.status,
            statusText: response.statusText,
            ok: response.ok,
            url: response.url
          }
      )

      if (!response.ok) {
        throw new Error(
            `Definition catalog request failed: ${response.status}`
        )
      }

      const payload =
          await response.json()

      this.debugLog(
          "loadCatalog:payload",
          payload
      )

      if (
          !payload ||
          !Array.isArray(
              payload.definitions
          )
      ) {
        throw new Error(
            "Invalid definition catalog response. Expected { definitions: [] }."
        )
      }

      /*
       * IMPORTANT:
       *
       * Normalize every definition as it enters
       * the controller.
       */

      this.catalog =
          this.normalizeCatalog(
              payload.definitions
          )

      this.filteredCatalog =
          [...this.catalog]

      this.debugLog(
          "loadCatalog:complete",
          {
            count: this.catalog.length,
            source: payload.meta?.source,
            apiVersion:
            payload.meta?.api_version,
            definitions:
                this.catalog.map(
                    definition => ({
                      id: definition.id,
                      name: definition.name,
                      category:
                      definition.category,
                      fields:
                      definition.fields.length
                    })
                )
          }
      )

      this.render()
    } catch (error) {
      this.debugError(
          "loadCatalog:error",
          error
      )

      this.showError(
          "Unable to load the definition library."
      )
    } finally {
      this.setLoadingState(false)

      this.debugLog(
          "loadCatalog:finally"
      )
    }
  }

  /*
   * ============================================================
   * NORMALIZATION
   * ============================================================
   */

  normalizeCatalog(definitions) {
    if (!Array.isArray(definitions)) {
      return []
    }

    return definitions
        .filter(Boolean)
        .map(definition =>
            this.normalizeDefinition(
                definition
            )
        )
  }

  normalizeDefinition(definition) {
    const fields =
        Array.isArray(definition.fields)
            ? definition.fields
            : []

    const normalizedFields =
        fields.map(field => ({
          ...field,

          name:
              field.name ||
              field.key ||
              "",

          label:
              field.label ||
              field.name ||
              field.key ||
              "Untitled Field",

          type:
              field.type ||
              "string",

          required:
              Boolean(field.required),

          active:
              field.active !== false
        }))

    const requiredCount =
        normalizedFields.filter(
            field => field.required
        ).length

    const activeCount =
        normalizedFields.filter(
            field => field.active !== false
        ).length

    const id =
        definition.id ||
        definition.slug ||
        definition.key ||
        `definition-${Math.random()
            .toString(36)
            .slice(2, 10)}`

    return {
      ...definition,

      id,

      version:
          definition.version ||
          "1.0",

      name:
          definition.name ||
          definition.title ||
          definition.label ||
          "Untitled Definition",

      title:
          definition.title ||
          definition.name ||
          definition.label ||
          "Untitled Definition",

      description:
          definition.description ||
          "Production-ready entity definition.",

      category:
          String(
              definition.category ||
              "OTHER"
          ).toUpperCase(),

      tags:
          Array.isArray(
              definition.tags
          )
              ? definition.tags
              : [],

      icon:
          definition.icon ||
          "✦",

      color:
          definition.color ||
          "violet",

      fields:
      normalizedFields,

      field_count:
          Number.isFinite(
              Number(definition.field_count)
          )
              ? Number(definition.field_count)
              : normalizedFields.length,

      required_count:
          Number.isFinite(
              Number(definition.required_count)
          )
              ? Number(
                  definition.required_count
              )
              : requiredCount,

      active_count:
          Number.isFinite(
              Number(definition.active_count)
          )
              ? Number(
                  definition.active_count
              )
              : activeCount,

      popularity:
          Number.isFinite(
              Number(definition.popularity)
          )
              ? Number(
                  definition.popularity
              )
              : 0,

      featured:
          Boolean(definition.featured),

      new:
          Boolean(definition.new),

      is_new:
          Boolean(definition.is_new),

      popular:
          Boolean(definition.popular)
    }
  }

  /*
   * ============================================================
   * RENDER
   * ============================================================
   */

  render() {
    this.debugLog("render:start", {
      catalogCount:
      this.catalog.length,
      searchQuery:
      this.searchQuery,
      selectedCategory:
      this.selectedCategory,
      sortMode:
      this.sortMode
    })

    this.renderCategories()

    this.applyFilters()

    this.renderGrid()

    this.renderEmptyState()

    this.renderResultCount()

    this.renderClearSearch()

    this.updateSortButton()

    this.renderPreview()

    this.debugLog("render:complete", {
      catalogCount:
      this.catalog.length,
      filteredCount:
      this.filteredCatalog.length
    })
  }

  /*
   * ============================================================
   * SEARCH
   * ============================================================
   */

  searchChanged(event) {
    this.searchQuery =
        event.currentTarget.value
            .trim()
            .toLowerCase()

    this.debugLog(
        "searchChanged",
        {
          query:
          this.searchQuery
        }
    )

    this.applyFilters()
    this.renderGrid()
    this.renderEmptyState()
    this.renderResultCount()
    this.renderClearSearch()
  }

  searchKeydown(event) {
    if (event.key === "Escape") {
      this.clearSearch(event)
      return
    }

    if (event.key === "Enter") {
      const first =
          this.filteredCatalog[0]

      if (first) {
        this.selectDefinition(first)
      }
    }
  }

  clearSearch(event = null) {
    if (event) {
      event.preventDefault()
    }

    this.searchQuery = ""

    if (this.hasSearchTarget) {
      this.searchTarget.value = ""
    }

    this.applyFilters()
    this.renderGrid()
    this.renderEmptyState()
    this.renderResultCount()
    this.renderClearSearch()

    this.focusSearch()
  }

  renderClearSearch() {
    if (!this.hasClearSearchTarget) {
      return
    }

    const visible =
        this.searchQuery.length > 0

    this.clearSearchTarget.classList.toggle(
        "hidden",
        !visible
    )

    this.clearSearchTarget.classList.toggle(
        "flex",
        visible
    )
  }

  /*
   * ============================================================
   * CATEGORIES
   * ============================================================
   */

  renderCategories() {
    if (!this.hasCategoriesTarget) {
      return
    }

    const categorySet =
        new Set(
            this.catalog
                .map(
                    definition =>
                        String(
                            definition.category ||
                            "OTHER"
                        ).toUpperCase()
                )
                .filter(Boolean)
        )

    const categories = [
      "ALL",
      ...categorySet
    ]

    this.categoriesTarget.innerHTML =
        categories
            .map(category => {
              const active =
                  category ===
                  this.selectedCategory

              return `
<button
  type="button"
  class="shrink-0 rounded-xl border-2 px-3 py-2 text-[8px] font-black uppercase tracking-wider transition ${
                  active
                      ? "border-violet-300 bg-violet-100 text-violet-600"
                      : "border-slate-200 bg-white text-slate-400 hover:border-violet-200 hover:bg-violet-50 hover:text-violet-500"
              }"
  data-category="${this.escapeAttribute(
                  category
              )}"
  data-action="click->definition-library#selectCategory"
  aria-pressed="${active}"
>
  ${this.escapeHtml(category)}
</button>
`
            })
            .join("")
  }

  selectCategory(event) {
    const category =
        event.currentTarget.dataset.category ||
        "ALL"

    this.selectedCategory =
        category

    this.applyFilters()
    this.renderCategories()
    this.renderGrid()
    this.renderEmptyState()
    this.renderResultCount()
  }

  /*
   * ============================================================
   * FILTERING
   * ============================================================
   */

  applyFilters() {
    const query =
        this.searchQuery

    this.filteredCatalog =
        this.catalog.filter(
            definition => {
              const category =
                  String(
                      definition.category ||
                      "OTHER"
                  ).toUpperCase()

              const categoryMatches =
                  this.selectedCategory ===
                  "ALL" ||
                  category ===
                  this.selectedCategory

              if (!categoryMatches) {
                return false
              }

              if (!query) {
                return true
              }

              const searchableText = [
                definition.id,
                definition.name,
                definition.title,
                definition.description,
                definition.category,

                ...(Array.isArray(
                    definition.tags
                )
                    ? definition.tags
                    : []),

                ...(Array.isArray(
                    definition.fields
                )
                    ? definition.fields.flatMap(
                        field => [
                          field.name,
                          field.label,
                          field.type
                        ]
                    )
                    : [])
              ]
                  .filter(Boolean)
                  .join(" ")
                  .toLowerCase()

              return searchableText.includes(
                  query
              )
            }
        )

    this.sortDefinitions()

    this.debugLog(
        "applyFilters:complete",
        {
          resultCount:
          this.filteredCatalog.length
        }
    )
  }

  /*
   * ============================================================
   * SORTING
   * ============================================================
   */

  toggleSort(event = null) {
    if (event) {
      event.preventDefault()
    }

    const modes = [
      "az",
      "za",
      "popular",
      "newest",
      "featured"
    ]

    const index =
        modes.indexOf(
            this.sortMode
        )

    this.sortMode =
        modes[
        (index + 1) %
        modes.length
            ]

    this.sortDefinitions()
    this.renderGrid()
    this.updateSortButton()
  }

  sortDefinitions() {
    const items =
        [...this.filteredCatalog]

    switch (this.sortMode) {
      case "za":
        items.sort(
            (a, b) =>
                this.definitionName(
                    b
                ).localeCompare(
                    this.definitionName(a)
                )
        )
        break

      case "popular":
        items.sort(
            (a, b) =>
                Number(
                    b.popularity || 0
                ) -
                Number(
                    a.popularity || 0
                )
        )
        break

      case "newest":
        items.sort((a, b) => {
          const dateA =
              new Date(
                  a.created_at ||
                  a.createdAt ||
                  0
              ).getTime()

          const dateB =
              new Date(
                  b.created_at ||
                  b.createdAt ||
                  0
              ).getTime()

          return dateB - dateA
        })
        break

      case "featured":
        items.sort((a, b) => {
          const featuredA =
              a.featured ? 1 : 0

          const featuredB =
              b.featured ? 1 : 0

          if (
              featuredA !==
              featuredB
          ) {
            return (
                featuredB -
                featuredA
            )
          }

          return (
              Number(
                  b.popularity || 0
              ) -
              Number(
                  a.popularity || 0
              )
          )
        })
        break

      case "az":
      default:
        items.sort(
            (a, b) =>
                this.definitionName(
                    a
                ).localeCompare(
                    this.definitionName(b)
                )
        )
    }

    this.filteredCatalog =
        items
  }

  updateSortButton() {
    if (!this.hasSortButtonTarget) {
      return
    }

    const labels = {
      az: "A–Z",
      za: "Z–A",
      popular: "POPULAR",
      newest: "NEWEST",
      featured: "FEATURED"
    }

    const label =
        labels[this.sortMode] ||
        "A–Z"

    this.sortButtonTarget.textContent =
        label

    this.sortButtonTarget.setAttribute(
        "aria-label",
        `Sort definitions: ${label}`
    )
  }

  /*
   * ============================================================
   * GRID
   * ============================================================
   */

  renderGrid() {
    if (!this.hasGridTarget) {
      this.debugLog(
          "grid:no-target"
      )

      return
    }

    /*
     * Always clear first.
     */

    this.gridTarget.innerHTML = ""

    if (
        !this.filteredCatalog.length
    ) {
      this.debugLog(
          "grid:empty"
      )

      return
    }

    this.filteredCatalog.forEach(
        (definition, index) => {
          this.gridTarget.insertAdjacentHTML(
              "beforeend",
              this.definitionCardHtml(
                  definition,
                  index
              )
          )
        }
    )

    this.debugLog(
        "grid:rendered",
        {
          count:
          this.filteredCatalog.length
        }
    )
  }

  definitionCardHtml(
      definition,
      index
  ) {
    const selected =
        this.selectedDefinition?.id ===
        definition.id

    const favorite =
        this.isFavorite(
            definition.id
        )

    const tags =
        Array.isArray(
            definition.tags
        )
            ? definition.tags.slice(
                0,
                3
            )
            : []

    const badges = []

    if (definition.featured) {
      badges.push("FEATURED")
    }

    if (
        definition.new ||
        definition.is_new
    ) {
      badges.push("NEW")
    }

    if (definition.popular) {
      badges.push("POPULAR")
    }

    return `
<article
  class="group relative cursor-pointer overflow-hidden rounded-3xl border-2 ${
        selected
            ? "border-violet-400 bg-violet-50/50 shadow-lg shadow-violet-100"
            : "border-slate-100 bg-white hover:border-violet-200 hover:shadow-lg hover:shadow-slate-200/50"
    } p-5 transition-all duration-200"
  tabindex="0"
  role="button"
  aria-label="Preview ${this.escapeAttribute(
        this.definitionName(
            definition
        )
    )}"
  aria-pressed="${selected}"
  data-definition-id="${this.escapeAttribute(
        definition.id
    )}"
  data-action="
    click->definition-library#selectDefinitionFromCard
    keydown->definition-library#cardKeydown
  "
>

  <div class="flex items-start justify-between gap-3">

    <div
      class="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl border-2 border-violet-100 bg-violet-50 text-lg text-violet-500"
    >
      ${this.escapeHtml(
        definition.icon || "✦"
    )}
    </div>

    <button
      type="button"
      class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border ${
        favorite
            ? "border-amber-200 bg-amber-50 text-amber-500"
            : "border-slate-100 bg-white text-slate-300"
    } transition hover:border-amber-200 hover:bg-amber-50 hover:text-amber-500"
      data-definition-id="${this.escapeAttribute(
        definition.id
    )}"
      data-action="click->definition-library#toggleFavorite"
      aria-label="${
        favorite
            ? "Remove from favorites"
            : "Add to favorites"
    }"
    >
      ${favorite ? "★" : "☆"}
    </button>

  </div>

  <div class="mt-4">

    <div class="flex flex-wrap gap-1.5">

      <span class="rounded-full border border-violet-100 bg-violet-50 px-2 py-1 text-[7px] font-black uppercase tracking-wider text-violet-500">
        ${this.escapeHtml(
        definition.category ||
        "OTHER"
    )}
      </span>

      ${badges
        .map(
            badge => `
            <span class="rounded-full border border-emerald-100 bg-emerald-50 px-2 py-1 text-[7px] font-black uppercase tracking-wider text-emerald-500">
              ${badge}
            </span>
          `
        )
        .join("")}

    </div>

    <h3 class="mt-3 truncate text-sm font-black text-slate-800">
      ${this.escapeHtml(
        this.definitionName(
            definition
        )
    )}
    </h3>

    <p class="mt-2 line-clamp-2 text-[10px] leading-5 text-slate-400">
      ${this.escapeHtml(
        definition.description ||
        ""
    )}
    </p>

  </div>

  <div class="mt-4 grid grid-cols-2 gap-2">

    <div class="rounded-xl bg-slate-50 p-2.5">
      <div class="text-[7px] font-black uppercase tracking-wider text-slate-400">
        FIELDS
      </div>

      <div class="mt-1 text-sm font-black text-slate-700">
        ${Number(
        definition.field_count ||
        0
    )}
      </div>
    </div>

    <div class="rounded-xl bg-slate-50 p-2.5">
      <div class="text-[7px] font-black uppercase tracking-wider text-slate-400">
        REQUIRED
      </div>

      <div class="mt-1 text-sm font-black text-orange-500">
        ${Number(
        definition.required_count ||
        0
    )}
      </div>
    </div>

  </div>

  ${
        tags.length
            ? `
        <div class="mt-4 flex flex-wrap gap-1">
          ${tags
                .map(
                    tag => `
                <span class="rounded-lg bg-slate-100 px-2 py-1 text-[7px] font-bold text-slate-400">
                  #${this.escapeHtml(
                        String(tag)
                    )}
                </span>
              `
                )
                .join("")}
        </div>
      `
            : ""
    }

</article>
`
  }

  /*
   * Separate action name makes the card action explicit.
   */

  selectDefinitionFromCard(event) {
    if (
        event.target.closest(
            "button"
        )
    ) {
      return
    }

    this.selectDefinitionFromElement(
        event.currentTarget
    )
  }

  cardKeydown(event) {
    if (
        event.key === "Enter" ||
        event.key === " "
    ) {
      event.preventDefault()

      this.selectDefinitionFromElement(
          event.currentTarget
      )
    }
  }

  selectDefinitionFromElement(
      element
  ) {
    const id =
        element.dataset.definitionId

    const definition =
        this.findDefinition(id)

    if (definition) {
      this.selectDefinition(
          definition
      )
    }
  }

  /*
   * ============================================================
   * PREVIEW
   * ============================================================
   */

  selectDefinition(
      definition
  ) {
    if (!definition) {
      return
    }

    this.selectedDefinition =
        this.normalizeDefinition(
            definition
        )

    this.activeTab =
        "fields"

    this.debugLog(
        "definition:selected",
        {
          id:
          this.selectedDefinition.id,
          name:
              this.definitionName(
                  this.selectedDefinition
              )
        }
    )

    this.addRecentlyViewed(
        this.selectedDefinition
    )

    this.trackUsage(
        this.selectedDefinition,
        "preview"
    )

    this.renderGrid()
    this.renderPreview()
  }

  renderPreview() {
    if (
        !this.hasPreviewTarget ||
        !this.hasPreviewEmptyTarget
    ) {
      return
    }

    if (
        !this.selectedDefinition
    ) {
      this.previewTarget.classList.add(
          "hidden"
      )

      this.previewTarget.classList.remove(
          "flex"
      )

      this.previewEmptyTarget.classList.remove(
          "hidden"
      )

      this.previewEmptyTarget.classList.add(
          "flex"
      )

      if (
          this.hasApplyButtonTarget
      ) {
        this.applyButtonTarget.disabled =
            true
      }

      return
    }

    const definition =
        this.selectedDefinition

    this.previewEmptyTarget.classList.add(
        "hidden"
    )

    this.previewEmptyTarget.classList.remove(
        "flex"
    )

    this.previewTarget.classList.remove(
        "hidden"
    )

    this.previewTarget.classList.add(
        "flex"
    )

    if (
        this.hasPreviewIconTarget
    ) {
      this.previewIconTarget.textContent =
          definition.icon || "✦"
    }

    if (
        this.hasPreviewTitleTarget
    ) {
      this.previewTitleTarget.textContent =
          this.definitionName(
              definition
          )
    }

    if (
        this.hasPreviewCategoryTarget
    ) {
      this.previewCategoryTarget.textContent =
          String(
              definition.category ||
              "OTHER"
          ).toUpperCase()
    }

    if (
        this.hasPreviewIdTarget
    ) {
      this.previewIdTarget.textContent =
          `${definition.id} · v${definition.version}`
    }

    if (
        this.hasPreviewDescriptionTarget
    ) {
      this.previewDescriptionTarget.textContent =
          definition.description || ""
    }

    const fields =
        Array.isArray(
            definition.fields
        )
            ? definition.fields
            : []

    const requiredCount =
        fields.filter(
            field =>
                Boolean(
                    field.required
                )
        ).length

    const activeCount =
        fields.filter(
            field =>
                field.active !== false
        ).length

    if (
        this.hasPreviewFieldCountTarget
    ) {
      this.previewFieldCountTarget.textContent =
          fields.length
    }

    if (
        this.hasPreviewRequiredCountTarget
    ) {
      this.previewRequiredCountTarget.textContent =
          requiredCount
    }

    if (
        this.hasPreviewActiveCountTarget
    ) {
      this.previewActiveCountTarget.textContent =
          activeCount
    }

    if (
        this.hasPreviewFieldSummaryTarget
    ) {
      this.previewFieldSummaryTarget.textContent =
          `${fields.length} FIELDS · ${requiredCount} REQUIRED`
    }

    this.renderFields()
    this.renderJson()
    this.updateTabs()

    if (
        this.hasApplyButtonTarget
    ) {
      this.applyButtonTarget.disabled =
          false
    }
  }

  renderFields() {
    if (!this.hasFieldListTarget) {
      return
    }

    const fields =
        Array.isArray(
            this.selectedDefinition?.fields
        )
            ? this.selectedDefinition.fields
            : []

    if (!fields.length) {
      this.fieldListTarget.innerHTML = `
<div class="p-6 text-center text-[10px] text-slate-400">
  No fields defined.
</div>
`

      return
    }

    this.fieldListTarget.innerHTML =
        fields
            .map(
                (field, index) => `
<div class="flex items-start justify-between gap-4 border-b border-slate-100 p-4 last:border-b-0">

  <div class="min-w-0">

    <div class="flex items-center gap-2">

      <span class="text-[10px] font-black text-slate-700">
        ${this.escapeHtml(
                    field.label ||
                    field.name ||
                    `Field ${index + 1}`
                )}
      </span>

      ${
                    field.required
                        ? `
            <span class="rounded-full bg-orange-50 px-1.5 py-0.5 text-[6px] font-black uppercase text-orange-500">
              REQUIRED
            </span>
          `
                        : ""
                }

    </div>

    <div class="mt-1 text-[8px] font-mono text-slate-400">
      ${this.escapeHtml(
                    field.name || ""
                )}
    </div>

  </div>

  <div class="shrink-0 text-right">

    <div class="rounded-lg bg-violet-50 px-2 py-1 text-[7px] font-black uppercase tracking-wider text-violet-500">
      ${this.escapeHtml(
                    field.type || "string"
                )}
    </div>

    <div class="mt-1 text-[7px] font-bold ${
                    field.active === false
                        ? "text-slate-300"
                        : "text-emerald-500"
                }">
      ${
                    field.active === false
                        ? "INACTIVE"
                        : "ACTIVE"
                }
    </div>

  </div>

</div>
`
            )
            .join("")
  }

  renderJson() {
    if (
        !this.hasPreviewJsonTarget ||
        !this.selectedDefinition
    ) {
      return
    }

    this.previewJsonTarget.textContent =
        JSON.stringify(
            this.selectedDefinition,
            null,
            2
        )
  }

  showFields(event = null) {
    event?.preventDefault()

    this.activeTab = "fields"

    this.updateTabs()
  }

  showJson(event = null) {
    event?.preventDefault()

    this.activeTab = "json"

    this.updateTabs()
  }

  updateTabs() {
    const fieldsActive =
        this.activeTab ===
        "fields"

    if (
        this.hasFieldsPanelTarget
    ) {
      this.fieldsPanelTarget.classList.toggle(
          "hidden",
          !fieldsActive
      )
    }

    if (
        this.hasJsonPanelTarget
    ) {
      this.jsonPanelTarget.classList.toggle(
          "hidden",
          fieldsActive
      )
    }

    if (
        this.hasFieldsTabTarget
    ) {
      this.setTabState(
          this.fieldsTabTarget,
          fieldsActive
      )
    }

    if (
        this.hasJsonTabTarget
    ) {
      this.setTabState(
          this.jsonTabTarget,
          !fieldsActive
      )
    }
  }

  setTabState(
      element,
      active
  ) {
    element.setAttribute(
        "aria-selected",
        String(active)
    )

    element.classList.toggle(
        "border-violet-500",
        active
    )

    element.classList.toggle(
        "text-violet-500",
        active
    )

    element.classList.toggle(
        "border-transparent",
        !active
    )

    element.classList.toggle(
        "text-slate-400",
        !active
    )
  }

  /*
   * ============================================================
   * COPY JSON
   * ============================================================
   */

  async copyJson(event = null) {
    event?.preventDefault()

    if (
        !this.selectedDefinition
    ) {
      return
    }

    const json =
        JSON.stringify(
            this.selectedDefinition,
            null,
            2
        )

    try {
      await navigator.clipboard.writeText(
          json
      )

      this.trackUsage(
          this.selectedDefinition,
          "copy_json"
      )
    } catch (error) {
      this.debugError(
          "json:copy-failed",
          error
      )
    }
  }

  /*
   * ============================================================
   * APPLY / IMPORT
   * ============================================================
   */

  apply(event = null) {
    event?.preventDefault()

    const definition =
        this.selectedDefinition

    if (!definition) {
      return
    }

    const detail = {
      definition,
      definition_id:
      definition.id,
      version:
      definition.version,
      source:
          "definition_library"
    }

    this.element.dispatchEvent(
        new CustomEvent(
            "definition-library:apply",
            {
              bubbles: true,
              detail
            }
        )
    )

    document.dispatchEvent(
        new CustomEvent(
            "definition-library:import",
            {
              bubbles: true,
              detail
            }
        )
    )

    window.dispatchEvent(
        new CustomEvent(
            "definition-library:definition-selected",
            {
              detail
            }
        )
    )

    this.trackUsage(
        definition,
        "import"
    )

    this.debugLog(
        "apply:events-dispatched",
        detail
    )
  }

  /*
   * ============================================================
   * FAVORITES
   * ============================================================
   */

  toggleFavorite(event) {
    event.preventDefault()
    event.stopPropagation()

    const id =
        event.currentTarget.dataset
            .definitionId

    if (!id) {
      return
    }

    if (
        this.isFavorite(id)
    ) {
      this.favorites =
          this.favorites.filter(
              favoriteId =>
                  favoriteId !== id
          )
    } else {
      this.favorites.push(id)
    }

    this.saveFavorites()

    this.renderGrid()

    const definition =
        this.findDefinition(id)

    if (definition) {
      this.trackUsage(
          definition,
          this.isFavorite(id)
              ? "favorite"
              : "unfavorite"
      )
    }
  }

  isFavorite(id) {
    return this.favorites.includes(
        id
    )
  }

  loadFavorites() {
    try {
      const value =
          localStorage.getItem(
              "definition-library:favorites"
          )

      const parsed =
          value
              ? JSON.parse(value)
              : []

      return Array.isArray(
          parsed
      )
          ? parsed
          : []
    } catch (error) {
      return []
    }
  }

  saveFavorites() {
    try {
      localStorage.setItem(
          "definition-library:favorites",
          JSON.stringify(
              this.favorites
          )
      )
    } catch (error) {
      this.debugError(
          "favorites:save-failed",
          error
      )
    }
  }

  /*
   * ============================================================
   * RECENT
   * ============================================================
   */

  addRecentlyViewed(
      definition
  ) {
    const id =
        definition.id

    this.recentlyViewed =
        this.recentlyViewed.filter(
            recentId =>
                recentId !== id
        )

    this.recentlyViewed.unshift(
        id
    )

    this.recentlyViewed =
        this.recentlyViewed.slice(
            0,
            10
        )

    try {
      localStorage.setItem(
          "definition-library:recent",
          JSON.stringify(
              this.recentlyViewed
          )
      )
    } catch (error) {
      this.debugError(
          "recent:save-failed",
          error
      )
    }
  }

  loadRecentlyViewed() {
    try {
      const value =
          localStorage.getItem(
              "definition-library:recent"
          )

      const parsed =
          value
              ? JSON.parse(value)
              : []

      return Array.isArray(
          parsed
      )
          ? parsed
          : []
    } catch (error) {
      return []
    }
  }

  /*
   * ============================================================
   * CLEAR FILTERS
   * ============================================================
   *
   * IMPORTANT:
   *
   * Your HTML calls:
   *
   * definition-library#clearAllFilters
   *
   * Your old controller only had:
   *
   * clearFilters
   *
   * So Stimulus was throwing:
   *
   * "references undefined method clearAllFilters"
   *
   * We support BOTH names now.
   */

  clearAllFilters(
      event = null
  ) {
    event?.preventDefault()

    this.debugLog(
        "filters:clear-all"
    )

    this.searchQuery = ""
    this.selectedCategory = "ALL"
    this.sortMode = "az"

    if (this.hasSearchTarget) {
      this.searchTarget.value = ""
    }

    this.render()
  }

  clearFilters(
      event = null
  ) {
    this.clearAllFilters(
        event
    )
  }

  /*
   * ============================================================
   * RESULT COUNT
   * ============================================================
   */

  renderResultCount() {
    if (
        !this.hasResultCountTarget
    ) {
      return
    }

    const count =
        this.filteredCatalog.length

    this.resultCountTarget.textContent =
        `${count} ${
            count === 1
                ? "DEFINITION"
                : "DEFINITIONS"
        }`
  }

  /*
   * ============================================================
   * EMPTY STATE
   * ============================================================
   */

  renderEmptyState() {
    if (
        !this.hasEmptyStateTarget ||
        !this.hasGridTarget
    ) {
      return
    }

    const empty =
        this.filteredCatalog.length ===
        0

    this.emptyStateTarget.classList.toggle(
        "hidden",
        !empty
    )

    this.emptyStateTarget.classList.toggle(
        "flex",
        empty
    )

    this.gridTarget.classList.toggle(
        "hidden",
        empty
    )
  }

  /*
   * ============================================================
   * LOADING / ERROR
   * ============================================================
   */

  setLoadingState(
      loading
  ) {
    this.loading =
        loading

    this.debugLog(
        "loading:changed",
        {
          loading
        }
    )

    if (loading) {
      this.setStatus(
          "LOADING"
      )

      if (this.hasGridTarget) {
        this.gridTarget.classList.remove(
            "hidden"
        )

        this.gridTarget.innerHTML = `
<div class="col-span-full flex min-h-[260px] items-center justify-center">
  <div class="text-center">

    <div class="mx-auto h-10 w-10 animate-spin rounded-full border-4 border-violet-100 border-t-violet-500"></div>

    <div class="mt-4 text-[9px] font-black uppercase tracking-[0.18em] text-violet-500">
      Loading definitions
    </div>

    <div class="mt-2 text-[10px] text-slate-400">
      Connecting to the definition catalog...
    </div>

  </div>
</div>
`
      }

      if (
          this.hasEmptyStateTarget
      ) {
        this.emptyStateTarget.classList.add(
            "hidden"
        )

        this.emptyStateTarget.classList.remove(
            "flex"
        )
      }

      return
    }

    this.setStatus(
        this.error
            ? "ERROR"
            : "CONNECTED"
    )
  }

  showError(
      message
  ) {
    this.error =
        new Error(message)

    this.setStatus(
        "ERROR"
    )

    if (
        !this.hasGridTarget
    ) {
      return
    }

    this.gridTarget.classList.remove(
        "hidden"
    )

    this.gridTarget.innerHTML = `
<div class="col-span-full flex min-h-[260px] items-center justify-center">
  <div class="max-w-md rounded-3xl border-2 border-red-100 bg-red-50 p-7 text-center">

    <div class="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-white text-xl text-red-400">
      !
    </div>

    <div class="mt-4 text-sm font-black text-slate-700">
      Unable to load definitions
    </div>

    <p class="mt-2 text-[10px] leading-5 text-slate-400">
      ${this.escapeHtml(
        message
    )}
    </p>

    <button
      type="button"
      class="mt-5 rounded-xl bg-violet-500 px-4 py-2.5 text-[8px] font-black uppercase tracking-wider text-white"
      data-action="click->definition-library#retryLoad"
    >
      TRY AGAIN
    </button>

  </div>
</div>
`
  }

  retryLoad(
      event = null
  ) {
    event?.preventDefault()

    this.error = null

    if (
        this.hasCatalogUrlValue &&
        this.catalogUrlValue
    ) {
      this.loadCatalog()
    } else {
      this.render()
    }
  }

  setStatus(
      status
  ) {
    if (
        !this.hasStatusTarget
    ) {
      return
    }

    this.statusTarget.textContent =
        String(
            status
        ).toUpperCase()

    const classes = [
      "border-emerald-100",
      "bg-emerald-50",
      "text-emerald-500",

      "border-orange-100",
      "bg-orange-50",
      "text-orange-500",

      "border-red-100",
      "bg-red-50",
      "text-red-500"
    ]

    this.statusTarget.classList.remove(
        ...classes
    )

    if (
        status ===
        "CONNECTED"
    ) {
      this.statusTarget.classList.add(
          "border-emerald-100",
          "bg-emerald-50",
          "text-emerald-500"
      )
    } else if (
        status === "LOADING"
    ) {
      this.statusTarget.classList.add(
          "border-orange-100",
          "bg-orange-50",
          "text-orange-500"
      )
    } else {
      this.statusTarget.classList.add(
          "border-red-100",
          "bg-red-50",
          "text-red-500"
      )
    }
  }

  /*
   * ============================================================
   * USAGE TRACKING
   * ============================================================
   */

  trackUsage(
      definition,
      eventType
  ) {
    if (!definition?.id) {
      return
    }

    if (
        !this.hasCatalogUsageUrlValue ||
        !this.catalogUsageUrlValue
    ) {
      return
    }

    const payload = {
      event_type:
      eventType,

      source:
          "definition_library",

      session_id:
          this.sessionId(),

      metadata: {
        definition_id:
        definition.id,

        version:
        definition.version
      }
    }

    fetch(
        this.catalogUsageUrlValue.replace(
            ":id",
            encodeURIComponent(
                definition.id
            )
        ),
        {
          method: "POST",

          headers: {
            "Content-Type":
                "application/json",

            Accept:
                "application/json",

            "X-CSRF-Token":
                this.csrfToken()
          },

          credentials:
              "same-origin",

          body:
              JSON.stringify(
                  payload
              )
        }
    ).catch(
        error => {
          console.warn(
              "[DefinitionLibrary] Usage tracking failed",
              error
          )
        }
    )
  }

  /*
   * ============================================================
   * SESSION / CSRF
   * ============================================================
   */

  sessionId() {
    return this.sessionIdValue
  }

  getOrCreateSessionId() {
    const storageKey =
        "definition-library:session-id"

    try {
      let id =
          sessionStorage.getItem(
              storageKey
          )

      if (!id) {
        id =
            `dl-${Date.now()}-${Math.random()
                .toString(36)
                .slice(2, 12)}`

        sessionStorage.setItem(
            storageKey,
            id
        )
      }

      return id
    } catch (error) {
      return `dl-${Date.now()}`
    }
  }

  csrfToken() {
    const meta =
        document.querySelector(
            'meta[name="csrf-token"]'
        )

    return meta?.content || ""
  }

  /*
   * ============================================================
   * KEYBOARD
   * ============================================================
   */

  handleGlobalKeydown(
      event
  ) {
    if (
        !this.hasModalTarget ||
        this.modalTarget.classList.contains(
            "hidden"
        )
    ) {
      return
    }

    if (
        event.key === "/" &&
        document.activeElement !==
        this.searchTarget
    ) {
      event.preventDefault()

      this.focusSearch()

      return
    }

    if (
        event.key === "Escape"
    ) {
      this.close(event)

      return
    }

    if (
        event.key === "Enter" &&
        (event.ctrlKey ||
            event.metaKey)
    ) {
      if (
          this.selectedDefinition
      ) {
        event.preventDefault()

        this.apply(event)
      }

      return
    }

    if (
        event.key ===
        "ArrowDown" ||
        event.key ===
        "ArrowRight" ||
        event.key ===
        "ArrowUp" ||
        event.key ===
        "ArrowLeft"
    ) {
      this.navigateCards(event)
    }
  }

  navigateCards(
      event
  ) {
    if (!this.hasGridTarget) {
      return
    }

    const cards =
        Array.from(
            this.gridTarget.querySelectorAll(
                "article[data-definition-id]"
            )
        )

    if (!cards.length) {
      return
    }

    const active =
        document.activeElement

    const currentIndex =
        cards.indexOf(active)

    if (
        currentIndex === -1
    ) {
      return
    }

    let nextIndex =
        currentIndex

    if (
        event.key ===
        "ArrowDown" ||
        event.key ===
        "ArrowRight"
    ) {
      nextIndex =
          Math.min(
              cards.length - 1,
              currentIndex + 1
          )
    }

    if (
        event.key ===
        "ArrowUp" ||
        event.key ===
        "ArrowLeft"
    ) {
      nextIndex =
          Math.max(
              0,
              currentIndex - 1
          )
    }

    if (
        nextIndex !==
        currentIndex
    ) {
      event.preventDefault()

      cards[
          nextIndex
          ].focus()
    }
  }

  focusSearch() {
    if (
        !this.hasSearchTarget
    ) {
      return
    }

    window.requestAnimationFrame(
        () => {
          this.searchTarget.focus()
          this.searchTarget.select()
        }
    )
  }

  /*
   * ============================================================
   * HELPERS
   * ============================================================
   */

  findDefinition(id) {
    return this.catalog.find(
        definition =>
            String(
                definition.id
            ) ===
            String(id)
    )
  }

  definitionName(
      definition
  ) {
    return (
        definition?.name ||
        definition?.title ||
        "Untitled Definition"
    )
  }

  escapeHtml(
      value
  ) {
    return String(
        value ?? ""
    )
        .replaceAll(
            "&",
            "&amp;"
        )
        .replaceAll(
            "<",
            "&lt;"
        )
        .replaceAll(
            ">",
            "&gt;"
        )
        .replaceAll(
            '"',
            "&quot;"
        )
        .replaceAll(
            "'",
            "&#039;"
        )
  }

  escapeAttribute(
      value
  ) {
    return this.escapeHtml(
        value
    )
  }
}