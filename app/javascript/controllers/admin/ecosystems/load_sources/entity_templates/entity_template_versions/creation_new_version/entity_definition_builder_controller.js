import { Controller } from "@hotwired/stimulus"

/*
 * Entity Definition Builder
 *
 * Responsibilities:
 * - Visual field builder
 * - JSON editor synchronization
 * - Definition library integration
 * - Field add/edit/delete
 * - Builder statistics
 * - Form submit validation
 * - Debug instrumentation
 *
 * Important library behavior:
 *
 * Library records may look like:
 *
 * {
 *   fields: [],
 *   definition_json: {
 *     fields: [...]
 *   }
 * }
 *
 * This controller therefore explicitly unwraps definition_json
 * before extracting fields.
 */

export default class extends Controller {
  static targets = [
    "headerStatusDot",
    "headerStatus",
    "xp",
    "progressLabel",
    "progressBar",

    "fieldEditor",
    "fieldEditorTitle",
    "fieldName",
    "fieldLabel",
    "fieldType",
    "fieldDescription",

    "requiredIcon",
    "requiredLabel",

    "multipleIcon",
    "multipleLabel",

    "activeIcon",
    "activeLabel",

    "builder",
    "fieldCount",
    "syncBadge",

    "statusDot",
    "status",
    "activity",

    "json",
    "jsonError",
    "jsonErrorMessage",

    "sidebarStatus",
    "sidebarFieldCount",
    "sidebarRequiredCount",
    "sidebarActiveCount",
    "health",
    "healthBar",

    "missionFieldIcon",

    "submitReadiness",
    "submit",

    "toast",
    "toastIcon",
    "toastTitle",
    "toastMessage"
  ]

  connect() {
    this.debug("CONNECT", {
      identifier: this.identifier,
      element: this.element,
      elementTag: this.element?.tagName,
      elementClasses: this.element?.className
    })

    this.debugTargetInventory()

    this.fieldEditingIndex = null
    this.fieldRequired = false
    this.fieldMultiple = false
    this.fieldActive = true
    this.toastTimer = null

    /*
     * Listen globally for the definition library event.
     *
     * This makes the builder independent of whether the library
     * modal is nested inside the builder element or elsewhere
     * in the DOM.
     */
    this.handleLibraryApply = this.handleLibraryApply.bind(this)

    document.addEventListener(
      "definition-library:apply",
      this.handleLibraryApply
    )

    /*
     * Also listen for the open event so the library can be opened
     * reliably from the builder.
     */
    this.handleLibraryOpen = this.handleLibraryOpen.bind(this)

    document.addEventListener(
      "definition-library:open",
      this.handleLibraryOpen
    )

    this.debug("STATE INITIALIZED", {
      fieldEditingIndex: this.fieldEditingIndex,
      fieldRequired: this.fieldRequired,
      fieldMultiple: this.fieldMultiple,
      fieldActive: this.fieldActive
    })

    this.initializeDefinition()

    this.debug("CONNECT COMPLETE")
  }

  disconnect() {
    this.debug("DISCONNECT")

    document.removeEventListener(
      "definition-library:apply",
      this.handleLibraryApply
    )

    document.removeEventListener(
      "definition-library:open",
      this.handleLibraryOpen
    )

    if (this.toastTimer) {
      clearTimeout(this.toastTimer)
      this.toastTimer = null
    }
  }

  // ============================================================
  // DEBUGGING
  // ============================================================

  get debugEnabled() {
    return window.ENTITY_BUILDER_DEBUG !== false
  }

  debug(message, payload = undefined) {
    if (!this.debugEnabled) return

    const prefix = "[ENTITY BUILDER]"

    if (payload === undefined) {
      console.log(`${prefix} ${message}`)
    } else {
      console.log(`${prefix} ${message}`, payload)
    }
  }

  debugJson(message, payload = undefined) {
    if (!this.debugEnabled) return

    const prefix = "[ENTITY BUILDER:JSON]"

    if (payload === undefined) {
      console.log(`${prefix} ${message}`)
    } else {
      console.log(`${prefix} ${message}`, payload)
    }
  }

  debugField(message, payload = undefined) {
    if (!this.debugEnabled) return

    const prefix = "[ENTITY BUILDER:FIELD]"

    if (payload === undefined) {
      console.log(`${prefix} ${message}`)
    } else {
      console.log(`${prefix} ${message}`, payload)
    }
  }

  debugLibrary(message, payload = undefined) {
    if (!this.debugEnabled) return

    const prefix = "[ENTITY BUILDER:LIBRARY]"

    if (payload === undefined) {
      console.log(`${prefix} ${message}`)
    } else {
      console.log(`${prefix} ${message}`, payload)
    }
  }

  debugSubmit(message, payload = undefined) {
    if (!this.debugEnabled) return

    const prefix = "[ENTITY BUILDER:SUBMIT]"

    if (payload === undefined) {
      console.log(`${prefix} ${message}`)
    } else {
      console.log(`${prefix} ${message}`, payload)
    }
  }

  debugTargetInventory() {
    const targets = [
      "json",
      "builder",
      "fieldEditor",
      "fieldName",
      "fieldLabel",
      "fieldType",
      "fieldDescription",
      "submit"
    ]

    const inventory = {}

    targets.forEach((name) => {
      const hasProperty =
        `has${name.charAt(0).toUpperCase()}${name.slice(1)}Target`

      inventory[name] = this[hasProperty] ?? false
    })

    this.debug("TARGET INVENTORY", inventory)
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  initializeDefinition() {
    this.debugJson("Initializing definition")

    if (!this.hasJsonTarget) {
      this.debugJson("JSON target is missing")
      this.fields = []
      this.renderFields()
      this.updateStats()
      this.setBuilderStatus("JSON target missing", "error")
      return
    }

    const raw = this.jsonTarget.value

    this.debugJson("Initial JSON textarea value", raw)

    if (!raw || !raw.trim()) {
      this.debugJson(
        "JSON is empty. Using default definition."
      )

      this.fields = []

      this.renderFields()
      this.syncJsonFromFields()
      this.updateStats()

      return
    }

    try {
      const parsed = JSON.parse(raw)

      this.debugJson(
        "Initial JSON parsed successfully",
        parsed
      )

      this.fields = this.extractFields(parsed)

      this.debugJson(
        "Fields extracted from initial JSON",
        {
          count: this.fields.length,
          fields: this.fields
        }
      )

      this.renderFields()
      this.updateStats()

      this.setBuilderStatus(
        this.fields.length > 0
          ? "Definition loaded"
          : "Definition builder ready",
        "success"
      )
    } catch (error) {
      this.debugJson(
        "INITIAL JSON PARSE FAILED",
        {
          error,
          message: error.message,
          raw
        }
      )

      this.fields = []

      this.renderFields()
      this.updateStats()

      this.showJsonError(
        `Invalid JSON: ${error.message}`
      )

      this.setBuilderStatus(
        "Invalid JSON",
        "error"
      )
    }
  }

  // ============================================================
  // DEFINITION / FIELD EXTRACTION
  // ============================================================

  extractFields(definition) {
    if (!definition || typeof definition !== "object") {
      this.debugJson(
        "Definition is not an object",
        definition
      )

      return []
    }

    /*
     * IMPORTANT:
     *
     * Your database object currently looks like:
     *
     * {
     *   fields: [],
     *   definition_json: {
     *     fields: [...]
     *   }
     * }
     *
     * We must prefer definition_json when the top-level fields
     * array is empty and definition_json contains fields.
     */

    const unwrapped = this.unwrapDefinitionJson(definition)

    this.debugJson(
      "Definition after unwrapping",
      unwrapped
    )

    if (
      Array.isArray(unwrapped.fields)
    ) {
      return unwrapped.fields.map((field) =>
        this.normalizeField(field)
      )
    }

    /*
     * Support:
     *
     * {
     *   fields: {
     *     email: {
     *       type: "string"
     *     }
     *   }
     * }
     */

    if (
      unwrapped.fields &&
      typeof unwrapped.fields === "object" &&
      !Array.isArray(unwrapped.fields)
    ) {
      return Object.entries(
        unwrapped.fields
      ).map(([name, field]) => {
        return this.normalizeField({
          ...(field || {}),
          name
        })
      })
    }

    this.debugJson(
      "No fields array/object found in definition",
      unwrapped
    )

    return []
  }

  unwrapDefinitionJson(definition) {
    if (
      !definition ||
      typeof definition !== "object"
    ) {
      return definition
    }

    /*
     * Handle:
     *
     * {
     *   definition_json: {
     *     fields: [...]
     *   }
     * }
     */

    if (definition.definition_json) {
      const nested =
        this.parsePossibleJson(
          definition.definition_json
        )

      if (
        nested &&
        typeof nested === "object"
      ) {
        /*
         * If nested definition actually has fields,
         * use it.
         */
        if (
          Array.isArray(nested.fields) &&
          nested.fields.length > 0
        ) {
          this.debugLibrary(
            "Using fields from definition_json",
            nested
          )

          return nested
        }

        if (
          nested.fields &&
          typeof nested.fields === "object"
        ) {
          this.debugLibrary(
            "Using object fields from definition_json",
            nested
          )

          return nested
        }
      }
    }

    /*
     * Handle nested:
     *
     * {
     *   definition: {
     *     fields: [...]
     *   }
     * }
     */

    if (
      definition.definition &&
      typeof definition.definition === "object"
    ) {
      return this.unwrapDefinitionJson(
        definition.definition
      )
    }

    return definition
  }

  parsePossibleJson(value) {
    if (typeof value !== "string") {
      return value
    }

    try {
      return JSON.parse(value)
    } catch (error) {
      this.debugJson(
        "Could not parse nested JSON string",
        {
          value,
          error: error.message
        }
      )

      return value
    }
  }

  normalizeField(field = {}) {
    return {
      name: String(
        field.name ||
        field.key ||
        ""
      ).trim(),

      label: String(
        field.label ||
        field.title ||
        field.name ||
        field.key ||
        ""
      ).trim(),

      type: String(
        field.type ||
        "string"
      ),

      description: String(
        field.description ||
        ""
      ),

      required: Boolean(
        field.required
      ),

      multiple: Boolean(
        field.multiple ??
        field.array ??
        false
      ),

      active:
        field.active === undefined
          ? true
          : Boolean(field.active)
    }
  }

  normalizeDefinition(definition) {
    if (typeof definition === "string") {
      this.debugLibrary(
        "Library definition is a string. Parsing JSON."
      )

      return this.normalizeDefinition(
        JSON.parse(definition)
      )
    }

    if (
      definition &&
      typeof definition === "object" &&
      definition.definition
    ) {
      this.debugLibrary(
        "Library payload contains nested definition property."
      )

      return this.normalizeDefinition(
        definition.definition
      )
    }

    if (
      definition &&
      typeof definition === "object" &&
      definition.definition_json
    ) {
      this.debugLibrary(
        "Library payload contains definition_json."
      )

      const nested =
        this.parsePossibleJson(
          definition.definition_json
        )

      if (
        nested &&
        typeof nested === "object"
      ) {
        return nested
      }
    }

    if (
      !definition ||
      typeof definition !== "object"
    ) {
      throw new Error(
        "Definition must be a JSON object."
      )
    }

    return definition
  }

  // ============================================================
  // QUICK START / LIBRARY
  // ============================================================

  openLibrary(event) {
    event?.preventDefault()

    this.debugLibrary(
      "openLibrary action received",
      {
        eventType: event?.type,
        target: event?.currentTarget
      }
    )

    const libraryElements =
      document.querySelectorAll(
        '[data-controller~="definition-library"]'
      )

    this.debugLibrary(
      "Definition library controller elements found",
      {
        count: libraryElements.length,
        elements: Array.from(libraryElements)
      }
    )

    if (libraryElements.length === 0) {
      this.debugLibrary(
        "ERROR: No definition-library controller found in DOM"
      )

      this.showToast(
        "LIBRARY NOT FOUND",
        "The definition library controller is not connected.",
        "error"
      )

      return
    }

    const libraryElement =
      libraryElements[0]

    this.debugLibrary(
      "Dispatching open request to library",
      libraryElement
    )

    libraryElement.dispatchEvent(
      new CustomEvent(
        "definition-library:open",
        {
          bubbles: true,
          detail: {
            source:
              "entity-definition-builder"
          }
        }
      )
    )
  }

  /*
   * Receives the open event if the library controller listens
   * at document level.
   */
  handleLibraryOpen(event) {
    this.debugLibrary(
      "definition-library:open received",
      event?.detail
    )
  }

  /*
   * Global event handler.
   *
   * This is intentionally separate from applyLibrary so that
   * the library event works even when the modal is outside the
   * builder DOM element.
   */
  handleLibraryApply(event) {
    this.debugLibrary(
      "GLOBAL definition-library:apply received",
      {
        detail: event?.detail,
        target: event?.target,
        currentTarget: event?.currentTarget
      }
    )

    this.applyLibrary(event)
  }

  applyLibrary(event) {
    this.debugLibrary(
      "definition-library:apply event received",
      event?.detail
    )

    const detail =
      event?.detail ?? null

    /*
     * Support all common payload shapes:
     *
     * detail.definition
     * detail.value
     * detail.template
     * detail.selectedDefinition
     * detail itself
     */

    let definition =
      detail?.definition ??
      detail?.value ??
      detail?.template ??
      detail?.selectedDefinition ??
      detail

    if (!definition) {
      this.debugLibrary(
        "ERROR: Library apply event contained no definition"
      )

      this.showToast(
        "IMPORT FAILED",
        "No definition was provided by the library.",
        "error"
      )

      return
    }

    this.debugLibrary(
      "Raw library definition received",
      definition
    )

    try {
      const normalized =
        this.normalizeDefinition(
          definition
        )

      this.debugLibrary(
        "Normalized library definition",
        normalized
      )

      /*
       * extractFields now understands:
       *
       * fields
       * definition_json.fields
       * object-style fields
       */
      const fields =
        this.extractFields(
          normalized
        )

      this.debugLibrary(
        "Fields extracted from library definition",
        {
          count: fields.length,
          fields
        }
      )

      if (fields.length === 0) {
        /*
         * One more fallback in case the library sends the full
         * ActiveRecord-style object:
         *
         * {
         *   fields: [],
         *   definition_json: {
         *     fields: [...]
         *   }
         * }
         */

        const fallbackFields =
          this.extractFields(
            definition
          )

        if (fallbackFields.length > 0) {
          this.debugLibrary(
            "Fallback extraction succeeded",
            {
              count:
                fallbackFields.length,
              fields:
                fallbackFields
            }
          )

          this.fields =
            fallbackFields
        } else {
          this.fields = []
        }
      } else {
        this.fields = fields
      }

      this.debugLibrary(
        "FINAL IMPORT FIELD STATE",
        {
          count:
            this.fields.length,
          fields:
            this.fields
        }
      )

      this.renderFields()

      this.syncJsonFromFields()

      this.updateStats()

      /*
       * Close the library after successful import if the
       * library exposes a close method through its DOM/controller.
       */
      this.closeLibraryModal()

      this.setBuilderStatus(
        this.fields.length > 0
          ? "Library definition imported"
          : "Library definition contains no fields",
        this.fields.length > 0
          ? "success"
          : "error"
      )

      if (this.fields.length > 0) {
        this.showToast(
          "DEFINITION IMPORTED",
          `${this.fields.length} field${
  this.fields.length === 1
      ? ""
      : "s"
} imported.`,
          "success"
        )
      } else {
        this.showToast(
          "NO FIELDS FOUND",
          "The selected definition does not contain any importable fields.",
          "error"
        )
      }
    } catch (error) {
      this.debugLibrary(
        "LIBRARY APPLY FAILED",
        {
          error,
          message:
            error.message,
          definition
        }
      )

      this.showToast(
        "IMPORT FAILED",
        error.message,
        "error"
      )
    }
  }

  closeLibraryModal() {
    /*
     * The library normally closes itself when APPLY is clicked.
     *
     * This method intentionally does not force-close arbitrary
     * elements. It only logs that the import completed.
     */
    this.debugLibrary(
      "Library import completed; library modal may now close."
    )
  }

  // ============================================================
  // FIELD EDITOR
  // ============================================================

  openFieldEditor(event) {
    event?.preventDefault()

    this.debugField(
      "Opening field editor"
    )

    if (!this.hasFieldEditorTarget) {
      this.debugField(
        "ERROR: fieldEditor target missing"
      )

      return
    }

    this.fieldEditingIndex = null

    this.fieldEditorTitleTarget.textContent =
      "Add definition field"

    this.resetFieldEditor()

    this.fieldEditorTarget.classList.remove(
      "hidden"
    )

    if (this.hasFieldNameTarget) {
      this.fieldNameTarget.focus()
    }

    this.debugField(
      "Field editor opened"
    )
  }

  editField(event) {
    event?.preventDefault()

    const index = Number(
      event?.currentTarget?.dataset?.fieldIndex
    )

    this.debugField(
      "editField action",
      {
        index,
        dataset:
          event?.currentTarget?.dataset
      }
    )

    if (
      Number.isNaN(index) ||
      !this.fields[index]
    ) {
      this.debugField(
        "ERROR: Cannot edit field. Invalid index.",
        {
          index,
          fields:
            this.fields
        }
      )

      return
    }

    const field =
      this.fields[index]

    this.fieldEditingIndex =
      index

    this.fieldEditorTitleTarget.textContent =
      "Edit definition field"

    this.fieldNameTarget.value =
      field.name

    this.fieldLabelTarget.value =
      field.label

    this.fieldTypeTarget.value =
      field.type

    this.fieldDescriptionTarget.value =
      field.description

    this.fieldRequired =
      field.required

    this.fieldMultiple =
      field.multiple

    this.fieldActive =
      field.active

    this.refreshToggleUI()

    this.fieldEditorTarget.classList.remove(
      "hidden"
    )

    this.fieldNameTarget.focus()

    this.debugField(
      "Field editor populated",
      {
        index,
        field
      }
    )
  }

  closeFieldEditor(event) {
    event?.preventDefault()

    this.debugField(
      "Closing field editor"
    )

    if (this.hasFieldEditorTarget) {
      this.fieldEditorTarget.classList.add(
        "hidden"
      )
    }

    this.fieldEditingIndex = null

    this.resetFieldEditor()
  }

  resetFieldEditor() {
    if (!this.hasFieldNameTarget) {
      return
    }

    this.fieldNameTarget.value = ""
    this.fieldLabelTarget.value = ""
    this.fieldTypeTarget.value = "string"
    this.fieldDescriptionTarget.value = ""

    this.fieldRequired = false
    this.fieldMultiple = false
    this.fieldActive = true

    this.refreshToggleUI()
  }

  toggleFieldRequired(event) {
    event?.preventDefault()

    this.fieldRequired =
      !this.fieldRequired

    this.debugField(
      "Required toggled",
      this.fieldRequired
    )

    this.refreshToggleUI()
  }

  toggleFieldMultiple(event) {
    event?.preventDefault()

    this.fieldMultiple =
      !this.fieldMultiple

    this.debugField(
      "Multiple toggled",
      this.fieldMultiple
    )

    this.refreshToggleUI()
  }

  toggleFieldActive(event) {
    event?.preventDefault()

    this.fieldActive =
      !this.fieldActive

    this.debugField(
      "Active toggled",
      this.fieldActive
    )

    this.refreshToggleUI()
  }

  refreshToggleUI() {
    if (this.hasRequiredIconTarget) {
      this.requiredIconTarget.textContent =
        this.fieldRequired
          ? "✓"
          : "○"

      this.requiredIconTarget.classList.toggle(
        "bg-orange-100",
        this.fieldRequired
      )

      this.requiredIconTarget.classList.toggle(
        "text-orange-500",
        this.fieldRequired
      )

      this.requiredIconTarget.classList.toggle(
        "bg-slate-50",
        !this.fieldRequired
      )

      this.requiredIconTarget.classList.toggle(
        "text-slate-300",
        !this.fieldRequired
      )
    }

    if (this.hasRequiredLabelTarget) {
      this.requiredLabelTarget.textContent =
        this.fieldRequired
          ? "Required"
          : "Optional"
    }

    if (this.hasMultipleIconTarget) {
      this.multipleIconTarget.textContent =
        this.fieldMultiple
          ? "✓"
          : "○"
    }

    if (this.hasMultipleLabelTarget) {
      this.multipleLabelTarget.textContent =
        this.fieldMultiple
          ? "Multiple"
          : "Single"
    }

    if (this.hasActiveIconTarget) {
      this.activeIconTarget.textContent =
        this.fieldActive
          ? "●"
          : "○"
    }

    if (this.hasActiveLabelTarget) {
      this.activeLabelTarget.textContent =
        this.fieldActive
          ? "Enabled"
          : "Disabled"
    }
  }

  saveField(event) {
    event?.preventDefault()

    const field = {
      name:
        this.fieldNameTarget.value.trim(),

      label:
        this.fieldLabelTarget.value.trim(),

      type:
        this.fieldTypeTarget.value,

      description:
        this.fieldDescriptionTarget.value.trim(),

      required:
        this.fieldRequired,

      multiple:
        this.fieldMultiple,

      active:
        this.fieldActive
    }

    this.debugField(
      "Attempting to save field",
      {
        editingIndex:
          this.fieldEditingIndex,
        field
      }
    )

    const validation =
      this.validateField(field)

    if (!validation.valid) {
      this.debugField(
        "FIELD VALIDATION FAILED",
        validation
      )

      this.showToast(
        "FIELD NOT SAVED",
        validation.message,
        "error"
      )

      return
    }

    if (
      this.fieldEditingIndex === null
    ) {
      this.fields.push(field)

      this.debugField(
        "New field added",
        {
          field,
          newCount:
            this.fields.length
        }
      )
    } else {
      const oldField =
        this.fields[
          this.fieldEditingIndex
        ]

      this.fields[
        this.fieldEditingIndex
      ] = field

      this.debugField(
        "Existing field updated",
        {
          index:
            this.fieldEditingIndex,
          oldField,
          newField:
            field
        }
      )
    }

    this.renderFields()
    this.syncJsonFromFields()
    this.updateStats()

    this.closeFieldEditor()

    this.setBuilderStatus(
      "Definition updated",
      "success"
    )

    this.showToast(
      "FIELD SAVED",
      `${
  field.label ||
  field.name
} is now part of the definition.`,
      "success"
    )
  }

  validateField(field) {
    if (!field.name) {
      return {
        valid: false,
        message:
          "Field name is required."
      }
    }

    if (
      !/^[a-zA-Z0-9_-]+$/.test(
        field.name
      )
    ) {
      return {
        valid: false,
        message:
          "Field name may contain letters, numbers, underscores and hyphens only."
      }
    }

    const duplicate =
      this.fields.some(
        (existing, index) =>
          existing.name === field.name &&
          index !==
            this.fieldEditingIndex
      )

    if (duplicate) {
      return {
        valid: false,
        message:
          `A field named "${field.name}" already exists.`
      }
    }

    if (!field.type) {
      return {
        valid: false,
        message:
          "Field type is required."
      }
    }

    return {
      valid: true
    }
  }

  deleteField(event) {
    event?.preventDefault()

    const index = Number(
      event?.currentTarget?.dataset?.fieldIndex
    )

    this.debugField(
      "deleteField action",
      {
        index
      }
    )

    if (
      Number.isNaN(index) ||
      !this.fields[index]
    ) {
      this.debugField(
        "ERROR: Invalid delete index",
        {
          index,
          fields:
            this.fields
        }
      )

      return
    }

    const removed =
      this.fields.splice(
        index,
        1
      )[0]

    this.debugField(
      "Field removed",
      {
        index,
        removed,
        remainingCount:
          this.fields.length
      }
    )

    this.renderFields()
    this.syncJsonFromFields()
    this.updateStats()

    this.setBuilderStatus(
      "Definition updated",
      "success"
    )

    this.showToast(
      "FIELD REMOVED",
      `${
  removed.label ||
  removed.name
} was removed.`,
      "success"
    )
  }

  // ============================================================
  // RENDER FIELD INVENTORY
  // ============================================================

  renderFields() {
    if (!this.hasBuilderTarget) {
      this.debugField(
        "ERROR: builder target missing"
      )

      return
    }

    this.debugField(
      "Rendering field inventory",
      {
        count:
          this.fields.length,
        fields:
          this.fields
      }
    )

    if (this.fields.length === 0) {
      this.builderTarget.innerHTML = `
<div class="rounded-2xl border-2 border-dashed border-slate-200 bg-slate-50/70 p-8 text-center">
    <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-white text-xl text-slate-300 shadow-sm">
    ◈
</div>

<div class="mt-3 text-xs font-black text-slate-500">
  No definition fields yet
</div>

<div class="mt-1 text-[9px] text-slate-400">
  Add a field or import a ready definition.
</div>
</div>
`

      return
    }

    this.builderTarget.innerHTML =
      this.fields
        .map((field, index) =>
          this.renderField(
            field,
            index
          )
        )
        .join("")
  }

  renderField(field, index) {
    const requiredClass =
      field.required
        ? "border-orange-200 bg-orange-50/50"
        : "border-slate-100 bg-white"

    const activeClass =
      field.active
        ? "text-emerald-500"
        : "text-slate-300"

    return `
<div
class="rounded-2xl border-2 ${requiredClass} p-4 shadow-sm transition hover:shadow-md"
data-field-index="${index}"
    >
    <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">

    <div class="flex min-w-0 items-start gap-3">

    <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-violet-50 font-mono text-xs font-black text-violet-500">
    ${index + 1}
</div>

<div class="min-w-0">

  <div class="flex flex-wrap items-center gap-2">

          <span class="truncate font-mono text-xs font-black text-slate-700">
            ${this.escapeHtml(field.name)}
          </span>

    <span class="rounded-full bg-violet-50 px-2 py-1 text-[7px] font-black uppercase tracking-wider text-violet-500">
            ${this.escapeHtml(field.type)}
          </span>

    ${
    field.required
        ? `
                <span class="rounded-full bg-orange-50 px-2 py-1 text-[7px] font-black uppercase tracking-wider text-orange-500">
                  REQUIRED
                </span>
              `
        : ""
  }

    ${
    field.multiple
        ? `
                <span class="rounded-full bg-sky-50 px-2 py-1 text-[7px] font-black uppercase tracking-wider text-sky-500">
                  MULTIPLE
                </span>
              `
        : ""
  }

  </div>

  <div class="mt-1 text-[10px] font-semibold text-slate-500">
    ${this.escapeHtml(
      field.label ||
      field.name
  )}
  </div>

  ${
  field.description
      ? `
              <div class="mt-1 text-[9px] leading-4 text-slate-400">
                ${this.escapeHtml(
          field.description
      )}
              </div>
            `
      : ""
}

</div>

</div>

<div class="flex shrink-0 items-center gap-2">

      <span class="text-[8px] font-black uppercase tracking-wider ${activeClass}">
        ${
        field.active
            ? "ACTIVE"
            : "INACTIVE"
      }
      </span>

  <button
      type="button"
      class="rounded-xl border border-violet-100 bg-violet-50 px-3 py-2 text-[8px] font-black uppercase tracking-wider text-violet-500 transition hover:border-violet-200 hover:bg-violet-100"
      data-field-index="${index}"
      data-action="click->entity-definition-builder#editField"
  >
    EDIT
  </button>

  <button
      type="button"
      class="rounded-xl border border-red-100 bg-red-50 px-3 py-2 text-[8px] font-black uppercase tracking-wider text-red-400 transition hover:border-red-200 hover:bg-red-100"
      data-field-index="${index}"
      data-action="click->entity-definition-builder#deleteField"
  >
    DELETE
  </button>

</div>

</div>
</div>
`
  }

  // ============================================================
  // JSON
  // ============================================================

  jsonChanged(event) {
    const value =
      event?.currentTarget?.value ??
      this.jsonTarget.value

    this.debugJson(
      "JSON input changed",
      {
        length:
          value.length,
        preview:
          value.slice(
            0,
            300
          )
      }
    )

    try {
      const parsed =
        JSON.parse(value)

      this.debugJson(
        "Manual JSON parsed successfully",
        parsed
      )

      const fields =
        this.extractFields(
          parsed
        )

      this.debugJson(
        "Manual JSON fields extracted",
        {
          count:
            fields.length,
          fields
        }
      )

      this.fields =
        fields

      this.renderFields()
      this.updateStats()
      this.clearJsonError()

      this.setBuilderStatus(
        "JSON synchronized",
        "success"
      )
    } catch (error) {
      this.debugJson(
        "MANUAL JSON PARSE FAILED",
        {
          message:
            error.message,
          error,
          value
        }
      )

      this.showJsonError(
        `Invalid JSON: ${error.message}`
      )

      this.setBuilderStatus(
        "JSON error",
        "error"
      )
    }
  }

  syncJsonFromFields() {
    if (!this.hasJsonTarget) {
      this.debugJson(
        "ERROR: Cannot sync. JSON target missing."
      )

      return
    }

    /*
     * IMPORTANT:
     *
     * The builder's canonical representation is:
     *
     * {
     *   fields: [...]
     * }
     *
     * This is what will be submitted by the form.
     */
    const definition = {
      fields:
        this.fields
    }

    const json =
      JSON.stringify(
        definition,
        null,
        2
      )

    this.debugJson(
      "Synchronizing visual builder -> JSON",
      {
        definition,
        json
      }
    )

    this.jsonTarget.value =
      json

    this.jsonTarget.dispatchEvent(
      new Event(
        "input",
        {
          bubbles: true
        }
      )
    )

    this.clearJsonError()

    this.debugJson(
      "Visual builder -> JSON synchronization complete"
    )
  }

  formatJson(event) {
    event?.preventDefault()

    this.debugJson(
      "FORMAT action"
    )

    if (!this.hasJsonTarget) {
      this.debugJson(
        "ERROR: JSON target missing"
      )

      return
    }

    try {
      const parsed =
        JSON.parse(
          this.jsonTarget.value
        )

      this.jsonTarget.value =
        JSON.stringify(
          parsed,
          null,
          2
        )

      this.clearJsonError()

      this.debugJson(
        "JSON formatted successfully"
      )

      this.jsonChanged({
        currentTarget:
          this.jsonTarget
      })
    } catch (error) {
      this.debugJson(
        "FORMAT FAILED",
        {
          error,
          message:
            error.message
        }
      )

      this.showJsonError(
        `Cannot format invalid JSON: ${error.message}`
      )
    }
  }

  showJsonError(message) {
    if (!this.hasJsonErrorTarget) {
      return
    }

    this.jsonErrorTarget.classList.remove(
      "hidden"
    )

    if (
      this.hasJsonErrorMessageTarget
    ) {
      this.jsonErrorMessageTarget.textContent =
        message
    }

    this.debugJson(
      "JSON error displayed",
      message
    )
  }

  clearJsonError() {
    if (!this.hasJsonErrorTarget) {
      return
    }

    this.jsonErrorTarget.classList.add(
      "hidden"
    )

    if (
      this.hasJsonErrorMessageTarget
    ) {
      this.jsonErrorMessageTarget.textContent =
        ""
    }
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  updateStats() {
    const fieldCount =
      this.fields.length

    const requiredCount =
      this.fields.filter(
        (field) =>
          field.required
      ).length

    const activeCount =
      this.fields.filter(
        (field) =>
          field.active
      ).length

    this.debug(
      "Updating statistics",
      {
        fieldCount,
        requiredCount,
        activeCount
      }
    )

    if (this.hasFieldCountTarget) {
      this.fieldCountTarget.textContent =
        `${fieldCount} FIELD${
  fieldCount === 1
      ? ""
      : "S"
}`
    }

    if (
      this.hasSidebarFieldCountTarget
    ) {
      this.sidebarFieldCountTarget.textContent =
        fieldCount
    }

    if (
      this.hasSidebarRequiredCountTarget
    ) {
      this.sidebarRequiredCountTarget.textContent =
        requiredCount
    }

    if (
      this.hasSidebarActiveCountTarget
    ) {
      this.sidebarActiveCountTarget.textContent =
        activeCount
    }

    const health =
      fieldCount === 0
        ? 100
        : Math.round(
            (activeCount /
              fieldCount) *
              100
          )

    if (this.hasHealthTarget) {
      this.healthTarget.textContent =
        `${health}%`
    }

    if (this.hasHealthBarTarget) {
      this.healthBarTarget.style.width =
        `${health}%`
    }

    const progress =
      Math.min(
        100,
        fieldCount > 0
          ? 25 +
            Math.min(
              requiredCount,
              3
            ) *
              15 +
            Math.min(
              activeCount,
              3
            ) *
              10
          : 0
      )

    if (
      this.hasProgressLabelTarget
    ) {
      this.progressLabelTarget.textContent =
        `${progress}%`
    }

    if (
      this.hasProgressBarTarget
    ) {
      this.progressBarTarget.style.width =
        `${progress}%`
    }

    const xp =
      Math.min(
        100,
        fieldCount * 15 +
          requiredCount * 10 +
          activeCount * 5
      )

    if (this.hasXpTarget) {
      this.xpTarget.textContent =
        xp
    }

    if (
      this.hasMissionFieldIconTarget
    ) {
      this.missionFieldIconTarget.textContent =
        fieldCount > 0
          ? "✓"
          : "01"

      this.missionFieldIconTarget.classList.toggle(
        "bg-emerald-100",
        fieldCount > 0
      )

      this.missionFieldIconTarget.classList.toggle(
        "text-emerald-500",
        fieldCount > 0
      )
    }

    this.updateReadiness()
  }

  updateReadiness() {
    const jsonValid =
      this.isJsonValid()

    const ready =
      jsonValid &&
      this.fields.length > 0

    this.debugSubmit(
      "Readiness evaluated",
      {
        jsonValid,
        fieldCount:
          this.fields.length,
        ready
      }
    )

    if (
      this.hasSubmitReadinessTarget
    ) {
      this.submitReadinessTarget.classList.toggle(
        "hidden",
        !ready
      )
    }

    if (
      this.hasSidebarStatusTarget
    ) {
      this.sidebarStatusTarget.textContent =
        ready
          ? "READY"
          : "CHECK"
    }
  }

  isJsonValid() {
    if (!this.hasJsonTarget) {
      return false
    }

    try {
      const parsed =
        JSON.parse(
          this.jsonTarget.value
        )

      return Boolean(
        parsed &&
          typeof parsed ===
            "object" &&
          !Array.isArray(parsed)
      )
    } catch {
      return false
    }
  }

  // ============================================================
  // STATUS
  // ============================================================

  setBuilderStatus(
    message,
    type = "success"
  ) {
    this.debug(
      "Builder status changed",
      {
        message,
        type
      }
    )

    if (this.hasStatusTarget) {
      this.statusTarget.textContent =
        message
    }

    if (this.hasActivityTarget) {
      this.activityTarget.textContent =
        message
    }

    if (this.hasStatusDotTarget) {
      this.statusDotTarget.className =
        type === "error"
          ? "h-2.5 w-2.5 rounded-full bg-red-400"
          : "h-2.5 w-2.5 rounded-full bg-emerald-400"
    }

    if (
      this.hasHeaderStatusTarget
    ) {
      this.headerStatusTarget.textContent =
        type === "error"
          ? "CHECK"
          : "READY"
    }

    if (
      this.hasHeaderStatusDotTarget
    ) {
      this.headerStatusDotTarget.className =
        type === "error"
          ? "h-2.5 w-2.5 rounded-full bg-red-400"
          : "h-2.5 w-2.5 rounded-full bg-emerald-400"
    }
  }

  // ============================================================
  // FORM SUBMIT
  // ============================================================

  beforeSubmit(event) {
    this.debugSubmit(
      "FORM SUBMIT INTERCEPTED",
      {
        event,
        fields:
          this.fields,
        json:
          this.hasJsonTarget
            ? this.jsonTarget.value
            : null
      }
    )

    /*
     * Always make sure the JSON submitted by Rails matches
     * the current visual field state.
     */
    if (
      this.hasJsonTarget &&
      this.fields
    ) {
      this.syncJsonFromFields()
    }

    const jsonValid =
      this.isJsonValid()

    if (!jsonValid) {
      event.preventDefault()

      this.debugSubmit(
        "SUBMIT BLOCKED: invalid JSON"
      )

      this.showJsonError(
        "Please provide valid JSON before creating the version."
      )

      this.showToast(
        "CANNOT CREATE VERSION",
        "The definition JSON is invalid.",
        "error"
      )

      return
    }

    if (
      this.fields.length === 0
    ) {
      event.preventDefault()

      this.debugSubmit(
        "SUBMIT BLOCKED: no fields"
      )

      this.showToast(
        "CANNOT CREATE VERSION",
        "Add at least one definition field.",
        "error"
      )

      return
    }

    this.debugSubmit(
      "SUBMIT VALIDATION PASSED"
    )

    this.setBuilderStatus(
      "Creating version...",
      "success"
    )
  }

  // ============================================================
  // TOAST
  // ============================================================

  showToast(
    title,
    message,
    type = "success"
  ) {
    if (!this.hasToastTarget) {
      this.debug(
        "Toast target missing",
        {
          title,
          message,
          type
        }
      )

      return
    }

    this.debug(
      "Toast",
      {
        title,
        message,
        type
      }
    )

    this.toastTarget.classList.remove(
      "hidden"
    )

    if (
      this.hasToastTitleTarget
    ) {
      this.toastTitleTarget.textContent =
        title
    }

    if (
      this.hasToastMessageTarget
    ) {
      this.toastMessageTarget.textContent =
        message
    }

    if (
      this.hasToastIconTarget
    ) {
      this.toastIconTarget.textContent =
        type === "error"
          ? "⚠"
          : "✦"
    }

    if (this.toastTimer) {
      clearTimeout(
        this.toastTimer
      )
    }

    this.toastTimer =
      setTimeout(() => {
        this.toastTarget.classList.add(
          "hidden"
        )
      }, 3500)
  }

  // ============================================================
  // UTILITIES
  // ============================================================

  escapeHtml(value) {
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
}
