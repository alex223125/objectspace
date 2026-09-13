import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "builder",
        "json",
        "jsonStatus",
        "jsonError",
        "jsonErrorMessage",

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

        "fieldCount",
        "syncBadge",

        "statusDot",
        "status",
        "activity",

        "xp",
        "progressBar",
        "progressLabel",

        "sidebarStatus",
        "sidebarFieldCount",
        "sidebarRequiredCount",
        "sidebarActiveCount",
        "health",
        "healthBar",

        "headerStatusDot",
        "headerStatus",

        "submit",
        "submitReadiness",

        "missionFieldIcon",

        "toast",
        "toastIcon",
        "toastTitle",
        "toastMessage"
    ]

    connect() {
        this.fields = []
        this.editingIndex = null

        this.xpValue = 0
        this.lastAction = null

        this.required = false
        this.multiple = false
        this.active = true

        this.initializeFromJson()
        this.render()

        this.dispatch("ready")
    }

    disconnect() {
        clearTimeout(this.toastTimer)
    }

    /* =========================================================
       INITIALIZATION
       ========================================================= */

    initializeFromJson() {
        try {
            const raw = this.jsonTarget.value.trim()

            if (!raw) {
                this.fields = []
                return
            }

            const parsed = JSON.parse(raw)

            if (Array.isArray(parsed.fields)) {
                this.fields = parsed.fields.map(field =>
                    this.normalizeField(field)
                )
            }
        } catch (_) {
            this.fields = []
        }
    }

    normalizeField(field) {
        return {
            name: field.name || "",
            label: field.label || field.name || "",
            type: field.type || "string",
            description: field.description || "",
            required: Boolean(field.required),
            multiple: Boolean(field.multiple),
            active: field.active !== false
        }
    }

    /* =========================================================
       LIBRARY
       ========================================================= */

    openLibrary() {
        this.dispatch("library-open")
    }

    applyLibrary(event) {
        const definition = event.detail.template

        if (!definition || !Array.isArray(definition.fields)) {
            this.showToast(
                "The selected library definition is invalid.",
                "LIBRARY ERROR",
                "⚠",
                "red"
            )

            return
        }

        this.fields = definition.fields.map(field =>
            this.normalizeField(field)
        )

        this.addXp(20)

        this.syncJson({
            message: `${event.detail.title} definition loaded.`
        })
    }

    /* =========================================================
       FIELD EDITOR
       ========================================================= */

    openFieldEditor() {
        this.editingIndex = null

        this.fieldEditorTitleTarget.textContent =
            "Add definition field"

        this.resetFieldEditor()

        this.fieldEditorTarget.classList.remove("hidden")

        this.fieldNameTarget.focus()
    }

    closeFieldEditor() {
        this.fieldEditorTarget.classList.add("hidden")
        this.editingIndex = null
    }

    editField(event) {
        const index = Number(event.detail.index)
        const field = this.fields[index]

        if (!field) return

        this.editingIndex = index

        this.fieldEditorTitleTarget.textContent =
            `Edit definition field`

        this.fieldNameTarget.value = field.name
        this.fieldLabelTarget.value = field.label
        this.fieldTypeTarget.value = field.type
        this.fieldDescriptionTarget.value = field.description

        this.required = field.required
        this.multiple = field.multiple
        this.active = field.active

        this.renderFieldEditorState()

        this.fieldEditorTarget.classList.remove("hidden")

        this.fieldNameTarget.focus()
    }

    saveField() {
        const field = {
            name: this.fieldNameTarget.value.trim(),
            label: this.fieldLabelTarget.value.trim(),
            type: this.fieldTypeTarget.value,
            description: this.fieldDescriptionTarget.value.trim(),
            required: this.required,
            multiple: this.multiple,
            active: this.active
        }

        const error = this.validateField(field)

        if (error) {
            this.showToast(error, "FIELD NEEDS ATTENTION", "⚠", "orange")
            return
        }

        if (this.editingIndex === null) {
            this.fields.push(field)

            this.addXp(10)

            this.showToast(
                `"${field.name}" added to the definition.`,
                "FIELD ADDED",
                "✦",
                "emerald"
            )
        } else {
            this.fields[this.editingIndex] = field

            this.addXp(5)

            this.showToast(
                `"${field.name}" updated.`,
                "FIELD UPDATED",
                "✓",
                "violet"
            )
        }

        this.closeFieldEditor()
        this.syncJson()
    }

    validateField(field) {
        if (!field.name) {
            return "Field name is required."
        }

        if (!/^[a-zA-Z][a-zA-Z0-9_]*$/.test(field.name)) {
            return "Field name must start with a letter and contain only letters, numbers and underscores."
        }

        const duplicate = this.fields.findIndex((existing, index) => {
            return existing.name === field.name &&
                index !== this.editingIndex
        })

        if (duplicate !== -1) {
            return `A field named "${field.name}" already exists.`
        }

        if (!field.label) {
            field.label = field.name
        }

        return null
    }

    resetFieldEditor() {
        this.fieldNameTarget.value = ""
        this.fieldLabelTarget.value = ""
        this.fieldTypeTarget.value = "string"
        this.fieldDescriptionTarget.value = ""

        this.required = false
        this.multiple = false
        this.active = true

        this.renderFieldEditorState()
    }

    toggleFieldRequired() {
        this.required = !this.required
        this.renderFieldEditorState()
    }

    toggleFieldMultiple() {
        this.multiple = !this.multiple
        this.renderFieldEditorState()
    }

    toggleFieldActive() {
        this.active = !this.active
        this.renderFieldEditorState()
    }

    renderFieldEditorState() {
        this.requiredIconTarget.textContent =
            this.required ? "✓" : "○"

        this.requiredLabelTarget.textContent =
            this.required ? "Required" : "Optional"

        this.multipleIconTarget.textContent =
            this.multiple ? "✓" : "○"

        this.multipleLabelTarget.textContent =
            this.multiple ? "Multiple values" : "Single"

        this.activeIconTarget.textContent =
            this.active ? "●" : "○"

        this.activeLabelTarget.textContent =
            this.active ? "Enabled" : "Disabled"

        this.requiredIconTarget.className =
            this.required
                ? "flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-100 text-emerald-500"
                : "flex h-8 w-8 items-center justify-center rounded-xl bg-slate-50 text-slate-300"

        this.multipleIconTarget.className =
            this.multiple
                ? "flex h-8 w-8 items-center justify-center rounded-xl bg-violet-100 text-violet-500"
                : "flex h-8 w-8 items-center justify-center rounded-xl bg-slate-50 text-slate-300"

        this.activeIconTarget.className =
            this.active
                ? "flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-50 text-emerald-400"
                : "flex h-8 w-8 items-center justify-center rounded-xl bg-slate-50 text-slate-300"
    }

    /* =========================================================
       FIELD INVENTORY
       ========================================================= */

    removeField(event) {
        const index = Number(event.detail.index)

        if (!this.fields[index]) return

        const removed = this.fields[index]

        this.fields.splice(index, 1)

        this.addXp(3)

        this.syncJson({
            message: `"${removed.name}" removed from the definition.`,
            icon: "−"
        })
    }

    moveField(event) {
        const index = Number(event.detail.index)
        const direction = Number(event.detail.direction)

        const destination = index + direction

        if (
            destination < 0 ||
            destination >= this.fields.length
        ) {
            return
        }

        const temporary = this.fields[index]

        this.fields[index] = this.fields[destination]
        this.fields[destination] = temporary

        this.addXp(2)

        this.syncJson({
            message: "Field order updated.",
            icon: "↕"
        })
    }

    /* =========================================================
       JSON SYNCHRONIZATION
       ========================================================= */

    syncJson(options = {}) {
        const definition = {
            fields: this.fields
        }

        this.jsonTarget.value =
            JSON.stringify(definition, null, 2)

        this.setJsonValid()

        this.render()

        this.animateSync()

        this.showToast(
            options.message || "Visual definition synchronized with JSON.",
            "DEFINITION UPDATED",
            options.icon || "↻",
            "violet"
        )

        this.dispatch("definition-changed", {
            detail: {
                definition
            }
        })
    }

    jsonChanged() {
        this.setJsonWorking()

        clearTimeout(this.jsonTimer)

        this.jsonTimer = setTimeout(() => {
            this.importJson()
        }, 350)
    }

    importJson() {
        try {
            const parsed = JSON.parse(this.jsonTarget.value)

            if (
                !parsed ||
                typeof parsed !== "object" ||
                !Array.isArray(parsed.fields)
            ) {
                this.setJsonInvalid(
                    'Definition must contain a "fields" array.'
                )

                return
            }

            const validationError =
                this.validateImportedFields(parsed.fields)

            if (validationError) {
                this.setJsonInvalid(validationError)
                return
            }

            this.fields = parsed.fields.map(field =>
                this.normalizeField(field)
            )

            this.setJsonValid()

            this.render()

            this.showToast(
                "Manual JSON changes imported into the visual builder.",
                "JSON IMPORTED",
                "✓",
                "emerald"
            )

            this.addXp(5)
        } catch (error) {
            this.setJsonInvalid(
                this.formatJsonError(error)
            )
        }
    }

    validateImportedFields(fields) {
        const names = new Set()

        for (let index = 0; index < fields.length; index++) {
            const field = fields[index]

            if (!field || typeof field !== "object") {
                return `Field ${index + 1} must be an object.`
            }

            if (!field.name) {
                return `Field ${index + 1} is missing "name".`
            }

            if (!/^[a-zA-Z][a-zA-Z0-9_]*$/.test(field.name)) {
                return `Field "${field.name}" has an invalid name.`
            }

            if (names.has(field.name)) {
                return `Duplicate field "${field.name}".`
            }

            names.add(field.name)

            if (!field.type) {
                return `Field "${field.name}" is missing "type".`
            }
        }

        return null
    }

    formatJsonError(error) {
        const message = error?.message || "Invalid JSON."

        const match = message.match(/position\s+(\d+)/i)

        if (!match) {
            return message
        }

        const position = Number(match[1])
        const raw = this.jsonTarget.value

        const before = raw.slice(0, position)
        const line = before.split("\n").length
        const column = position - before.lastIndexOf("\n")

        return `${message} Line ${line}, column ${column}.`
    }

    formatJson() {
        try {
            const parsed = JSON.parse(this.jsonTarget.value)

            this.jsonTarget.value =
                JSON.stringify(parsed, null, 2)

            this.setJsonValid()

            this.showToast(
                "JSON formatted successfully.",
                "JSON FORMATTED",
                "✓",
                "emerald"
            )
        } catch (error) {
            this.setJsonInvalid(
                this.formatJsonError(error)
            )

            this.showToast(
                "JSON could not be formatted because it is invalid.",
                "FORMAT FAILED",
                "⚠",
                "red"
            )
        }
    }

    setJsonWorking() {
        this.jsonStatusTarget.textContent = "CHECKING..."

        this.jsonStatusTarget.className =
            "rounded-full border border-amber-500/20 bg-amber-500/10 px-3 py-1.5 text-[8px] font-black uppercase tracking-wider text-amber-400"
    }

    setJsonValid() {
        this.jsonStatusTarget.textContent = "VALID JSON"

        this.jsonStatusTarget.className =
            "rounded-full border border-emerald-500/20 bg-emerald-500/10 px-3 py-1.5 text-[8px] font-black uppercase tracking-wider text-emerald-400"

        this.jsonErrorTarget.classList.add("hidden")
    }

    setJsonInvalid(message) {
        this.jsonStatusTarget.textContent = "INVALID JSON"

        this.jsonStatusTarget.className =
            "rounded-full border border-red-500/20 bg-red-500/10 px-3 py-1.5 text-[8px] font-black uppercase tracking-wider text-red-400"

        this.jsonErrorTarget.classList.remove("hidden")
        this.jsonErrorMessageTarget.textContent = message
    }

    /* =========================================================
       RENDER
       ========================================================= */

    render() {
        this.builderTarget.innerHTML = ""

        this.fields.forEach((field, index) => {
            this.builderTarget.insertAdjacentHTML(
                "beforeend",
                this.fieldCard(field, index)
            )
        })

        this.updateStatistics()
        this.updateMission()
        this.updateProgress()
    }

    fieldCard(field, index) {
        const statusClass = field.active
            ? "bg-emerald-50 text-emerald-500 border-emerald-100"
            : "bg-slate-100 text-slate-400 border-slate-200"

        return `
      <div
        class="
          group
          rounded-[28px]
          border-2
          border-slate-100
          bg-white
          p-5
          shadow-sm
          transition-all
          duration-300
          hover:-translate-y-0.5
          hover:border-violet-200
          hover:shadow-md
        "
        data-field-index="${index}"
      >

        <div class="flex items-start gap-4">

          <div class="
            flex
            h-11
            w-11
            shrink-0
            items-center
            justify-center
            rounded-2xl
            bg-gradient-to-br
            from-violet-100
            to-fuchsia-100
            text-sm
            font-black
            text-violet-500
          ">
            ${String(index + 1).padStart(2, "0")}
          </div>

          <div class="min-w-0 flex-1">

            <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">

              <div class="min-w-0">

                <div class="flex flex-wrap items-center gap-2">

                  <span class="font-mono text-sm font-black text-slate-700">
                    ${this.escapeHtml(field.name)}
                  </span>

                  <span class="
                    rounded-full
                    border
                    ${statusClass}
                    px-2
                    py-1
                    text-[8px]
                    font-black
                    uppercase
                    tracking-wider
                  ">
                    ${field.type}
                  </span>

                  ${field.required ? `
                    <span class="
                      rounded-full
                      border
                      border-orange-100
                      bg-orange-50
                      px-2
                      py-1
                      text-[8px]
                      font-black
                      uppercase
                      tracking-wider
                      text-orange-500
                    ">
                      REQUIRED
                    </span>
                  ` : ""}

                  ${field.multiple ? `
                    <span class="
                      rounded-full
                      border
                      border-violet-100
                      bg-violet-50
                      px-2
                      py-1
                      text-[8px]
                      font-black
                      uppercase
                      tracking-wider
                      text-violet-500
                    ">
                      MULTIPLE
                    </span>
                  ` : ""}

                </div>

                <div class="mt-1 text-xs font-bold text-slate-500">
                  ${this.escapeHtml(field.label || field.name)}
                </div>

                ${field.description ? `
                  <div class="mt-1 text-[10px] leading-5 text-slate-400">
                    ${this.escapeHtml(field.description)}
                  </div>
                ` : ""}

              </div>

              <div class="flex shrink-0 items-center gap-2">

                <button
                  type="button"
                  class="
                    flex
                    h-9
                    w-9
                    items-center
                    justify-center
                    rounded-xl
                    border
                    border-slate-100
                    bg-white
                    text-slate-400
                    transition
                    hover:border-violet-200
                    hover:bg-violet-50
                    hover:text-violet-500
                  "
                  data-action="click->entity-definition-builder#editField"
                  data-index="${index}"
                >
                  ✎
                </button>

                <button
                  type="button"
                  class="
                    flex
                    h-9
                    w-9
                    items-center
                    justify-center
                    rounded-xl
                    border
                    border-slate-100
                    bg-white
                    text-slate-400
                    transition
                    hover:border-red-200
                    hover:bg-red-50
                    hover:text-red-500
                  "
                  data-action="click->entity-definition-builder#removeField"
                  data-index="${index}"
                >
                  ×
                </button>

              </div>

            </div>

            <div class="mt-4 flex flex-wrap items-center gap-2">

              <button
                type="button"
                class="
                  rounded-xl
                  border
                  border-slate-100
                  bg-slate-50
                  px-3
                  py-2
                  text-[8px]
                  font-black
                  uppercase
                  tracking-wider
                  text-slate-400
                  transition
                  hover:border-violet-200
                  hover:bg-violet-50
                  hover:text-violet-500
                "
                data-action="click->entity-definition-builder#moveFieldUp"
                data-index="${index}"
              >
                ↑ MOVE
              </button>

              <button
                type="button"
                class="
                  rounded-xl
                  border
                  border-slate-100
                  bg-slate-50
                  px-3
                  py-2
                  text-[8px]
                  font-black
                  uppercase
                  tracking-wider
                  text-slate-400
                  transition
                  hover:border-violet-200
                  hover:bg-violet-50
                  hover:text-violet-500
                "
                data-action="click->entity-definition-builder#moveFieldDown"
                data-index="${index}"
              >
                ↓ MOVE
              </button>

            </div>

          </div>

        </div>

      </div>
    `
    }

    editField(event) {
        const index = Number(event.currentTarget.dataset.index)
        const field = this.fields[index]

        if (!field) return

        this.editingIndex = index

        this.fieldEditorTitleTarget.textContent =
            `Edit field #${index + 1}`

        this.fieldNameTarget.value = field.name
        this.fieldLabelTarget.value = field.label
        this.fieldTypeTarget.value = field.type
        this.fieldDescriptionTarget.value = field.description

        this.required = field.required
        this.multiple = field.multiple
        this.active = field.active

        this.renderFieldEditorState()

        this.fieldEditorTarget.classList.remove("hidden")

        this.fieldNameTarget.focus()
    }

    removeField(event) {
        const index = Number(event.currentTarget.dataset.index)

        if (!this.fields[index]) return

        const removed = this.fields[index]

        this.fields.splice(index, 1)

        this.addXp(3)

        this.syncJson({
            message: `"${removed.name}" removed from the definition.`,
            icon: "−"
        })
    }

    moveFieldUp(event) {
        const index = Number(event.currentTarget.dataset.index)

        if (index <= 0) return

        const temp = this.fields[index - 1]

        this.fields[index - 1] = this.fields[index]
        this.fields[index] = temp

        this.syncJson({
            message: "Field moved upward.",
            icon: "↑"
        })
    }

    moveFieldDown(event) {
        const index = Number(event.currentTarget.dataset.index)

        if (index >= this.fields.length - 1) return

        const temp = this.fields[index + 1]

        this.fields[index + 1] = this.fields[index]
        this.fields[index] = temp

        this.syncJson({
            message: "Field moved downward.",
            icon: "↓"
        })
    }

    /* =========================================================
       STATISTICS / GAMIFICATION
       ========================================================= */

    updateStatistics() {
        const count = this.fields.length

        const required =
            this.fields.filter(field => field.required).length

        const active =
            this.fields.filter(field => field.active).length

        this.fieldCountTarget.textContent =
            `${count} ${count === 1 ? "FIELD" : "FIELDS"}`

        this.sidebarFieldCountTarget.textContent = count
        this.sidebarRequiredCountTarget.textContent = required
        this.sidebarActiveCountTarget.textContent = active

        const health = count === 0
            ? 70
            : Math.min(
                100,
                70 +
                Math.min(count * 4, 20) +
                (required > 0 ? 5 : 0) +
                (active === count ? 5 : 0)
            )

        this.healthTarget.textContent = `${health}%`
        this.healthBarTarget.style.width = `${health}%`

        if (count === 0) {
            this.sidebarStatusTarget.textContent = "BUILDING"
            this.sidebarStatusTarget.className =
                "rounded-full border border-orange-100 bg-orange-50 px-2.5 py-1 text-[8px] font-black uppercase tracking-wider text-orange-500"
        } else {
            this.sidebarStatusTarget.textContent = "READY"
            this.sidebarStatusTarget.className =
                "rounded-full border border-emerald-100 bg-emerald-50 px-2.5 py-1 text-[8px] font-black uppercase tracking-wider text-emerald-500"
        }

        this.syncBadgeTarget.textContent = "SYNCED"
    }

    updateMission() {
        const count = this.fields.length

        if (count > 0) {
            this.missionFieldIconTarget.textContent = "✓"
            this.missionFieldIconTarget.className =
                "flex h-7 w-7 shrink-0 items-center justify-center rounded-xl bg-emerald-100 text-[9px] font-black text-emerald-500"
        } else {
            this.missionFieldIconTarget.textContent = "01"
            this.missionFieldIconTarget.className =
                "flex h-7 w-7 shrink-0 items-center justify-center rounded-xl bg-slate-100 text-[9px] font-black text-slate-300"
        }
    }

    updateProgress() {
        const count = this.fields.length
        const required =
            this.fields.filter(field => field.required).length

        let progress = 0

        if (count > 0) progress += 35
        if (count >= 3) progress += 20
        if (required > 0) progress += 15
        if (this.isJsonValid()) progress += 20
        if (count >= 5) progress += 10

        progress = Math.min(100, progress)

        this.progressBarTarget.style.width =
            `${progress}%`

        this.progressLabelTarget.textContent =
            `${progress}%`

        this.xpTarget.textContent =
            Math.min(100, this.xpValue)
    }

    addXp(amount) {
        this.xpValue =
            Math.min(100, this.xpValue + amount)

        this.xpTarget.textContent =
            this.xpValue

        this.updateProgress()
    }

    /* =========================================================
       SUBMIT
       ========================================================= */

    beforeSubmit(event) {
        if (!this.isJsonValid()) {
            event.preventDefault()

            this.showToast(
                "Fix the JSON definition before creating the version.",
                "MISSION BLOCKED",
                "⚠",
                "red"
            )

            this.jsonTarget.focus()

            return false
        }

        this.jsonTarget.value =
            JSON.stringify(
                {
                    fields: this.fields
                },
                null,
                2
            )

        this.submitTarget.disabled = true
        this.submitTarget.value = "CREATING VERSION..."

        this.showToast(
            "Definition validated. Creating template version...",
            "DEPLOYING",
            "🚀",
            "emerald"
        )

        return true
    }

    isJsonValid() {
        try {
            const parsed = JSON.parse(this.jsonTarget.value)

            if (
                !parsed ||
                typeof parsed !== "object" ||
                !Array.isArray(parsed.fields)
            ) {
                return false
            }

            return true
        } catch (_) {
            return false
        }
    }

    /* =========================================================
       VISUAL STATE
       ========================================================= */

    animateSync() {
        this.syncBadgeTarget.textContent = "SYNCING..."

        this.statusTarget.textContent =
            "Synchronizing definition..."

        this.statusDotTarget.className =
            "h-2.5 w-2.5 animate-pulse rounded-full bg-violet-400"

        this.headerStatusTarget.textContent = "SYNCING"

        this.headerStatusDotTarget.className =
            "h-2.5 w-2.5 animate-pulse rounded-full bg-violet-400"

        setTimeout(() => {
            this.syncBadgeTarget.textContent = "SYNCED"

            this.statusTarget.textContent =
                "Definition builder ready"

            this.statusDotTarget.className =
                "h-2.5 w-2.5 rounded-full bg-emerald-400"

            this.headerStatusTarget.textContent = "READY"

            this.headerStatusDotTarget.className =
                "h-2.5 w-2.5 animate-pulse rounded-full bg-emerald-400"

            this.activityTarget.textContent =
                "Definition synchronized successfully."
        }, 350)
    }

    showToast(
        message,
        title = "DEFINITION UPDATED",
        icon = "✦",
        tone = "violet"
    ) {
        this.toastTitleTarget.textContent = title
        this.toastMessageTarget.textContent = message
        this.toastIconTarget.textContent = icon

        const container =
            this.toastTarget.querySelector(
                "[data-notification-container]"
            )

        if (container) {
            const tones = {
                violet: [
                    "border-violet-100",
                    "shadow-violet-200/40"
                ],
                emerald: [
                    "border-emerald-100",
                    "shadow-emerald-200/40"
                ],
                orange: [
                    "border-orange-100",
                    "shadow-orange-200/40"
                ],
                red: [
                    "border-red-100",
                    "shadow-red-200/40"
                ]
            }

            Object.values(tones)
                .flat()
                .forEach(className => {
                    container.classList.remove(className)
                })

            ;(tones[tone] || tones.violet)
                .forEach(className => {
                    container.classList.add(className)
                })
        }

        this.toastTarget.classList.remove("hidden")

        clearTimeout(this.toastTimer)

        this.toastTimer = setTimeout(() => {
            this.toastTarget.classList.add("hidden")
        }, tone === "red" ? 4500 : 2200)
    }

    escapeHtml(value) {
        const div = document.createElement("div")
        div.textContent = value ?? ""
        return div.innerHTML
    }
}