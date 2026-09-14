import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "builder",
        "json",
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
        "status",
        "statusDot",
        "activity",

        "sidebarStatus",
        "sidebarFieldCount",
        "sidebarRequiredCount",
        "sidebarActiveCount",
        "health",
        "healthBar",

        "progressLabel",
        "progressBar",
        "xp",
        "missionFieldIcon",

        "submitReadiness",
        "submit",

        "headerStatus",
        "headerStatusDot",

        "toast",
        "toastIcon",
        "toastTitle",
        "toastMessage"
    ]

    connect() {
        this.fields = []
        this.editingIndex = null
        this.required = false
        this.multiple = false
        this.active = true
        this.toastTimer = null
        this.jsonValid = true

        this.initializeFromJson()
    }

    disconnect() {
        if (this.toastTimer) {
            window.clearTimeout(this.toastTimer)
        }
    }

    initializeFromJson() {
        const initial = this.readJson()

        if (!initial.valid) {
            this.fields = []
            this.setJsonError(initial.error)
            this.render()
            return
        }

        this.fields = this.normalizeFields(initial.value.fields)

        this.clearJsonError()
        this.render()
        this.updateJsonFromFields()
        this.setActivity("Definition builder ready.")
    }

    // ---------------------------------------------------------------------------
    // QUICK START
    // ---------------------------------------------------------------------------

    openFieldEditor() {
        this.editingIndex = null
        this.resetEditor()
        this.fieldEditorTitleTarget.textContent = "Add definition field"

        this.fieldEditorTarget.classList.remove("hidden")
        this.fieldNameTarget.focus()

        this.setActivity("Ready to add a definition field.")
    }

    closeFieldEditor() {
        this.fieldEditorTarget.classList.add("hidden")
        this.editingIndex = null
        this.resetEditor()
    }

    resetEditor() {
        this.fieldNameTarget.value = ""
        this.fieldLabelTarget.value = ""
        this.fieldTypeTarget.value = "string"
        this.fieldDescriptionTarget.value = ""

        this.required = false
        this.multiple = false
        this.active = true

        this.refreshToggleUI()
    }

    toggleFieldRequired() {
        this.required = !this.required
        this.refreshToggleUI()
    }

    toggleFieldMultiple() {
        this.multiple = !this.multiple
        this.refreshToggleUI()
    }

    toggleFieldActive() {
        this.active = !this.active
        this.refreshToggleUI()
    }

    refreshToggleUI() {
        this.setToggle(
            this.requiredIconTarget,
            this.requiredLabelTarget,
            this.required,
            "✓",
            "Required",
            "Optional",
            "bg-emerald-50",
            "text-emerald-500"
        )

        this.setToggle(
            this.multipleIconTarget,
            this.multipleLabelTarget,
            this.multiple,
            "✓",
            "Multiple",
            "Single",
            "bg-violet-50",
            "text-violet-500"
        )

        this.setToggle(
            this.activeIconTarget,
            this.activeLabelTarget,
            this.active,
            "●",
            "Enabled",
            "Disabled",
            "bg-emerald-50",
            "text-emerald-500"
        )
    }

    setToggle(
        icon,
        label,
        enabled,
        symbol,
        enabledText,
        disabledText,
        bgClass,
        textClass
    ) {
        icon.textContent = enabled ? symbol : "○"
        label.textContent = enabled ? enabledText : disabledText

        icon.classList.remove(
            "bg-slate-50",
            "text-slate-300",
            "bg-emerald-50",
            "text-emerald-500",
            "bg-violet-50",
            "text-violet-500"
        )

        if (enabled) {
            icon.classList.add(bgClass, textClass)
            label.classList.remove("text-slate-400")
            label.classList.add(textClass)
        } else {
            icon.classList.add("bg-slate-50", "text-slate-300")
            label.classList.remove(
                "text-emerald-500",
                "text-violet-500"
            )
            label.classList.add("text-slate-400")
        }
    }

    saveField() {
        const name = this.fieldNameTarget.value.trim()
        const label = this.fieldLabelTarget.value.trim()
        const type = this.fieldTypeTarget.value
        const description = this.fieldDescriptionTarget.value.trim()

        if (!name) {
            this.showToast(
                "FIELD REQUIRED",
                "Enter a field name before saving.",
                "warning"
            )

            this.fieldNameTarget.focus()
            return
        }

        if (!/^[a-zA-Z][a-zA-Z0-9_]*$/.test(name)) {
            this.showToast(
                "INVALID FIELD NAME",
                "Use letters, numbers and underscores. The name must begin with a letter.",
                "warning"
            )

            this.fieldNameTarget.focus()
            return
        }

        const duplicateIndex = this.fields.findIndex(
            (field, index) =>
                field.name === name && index !== this.editingIndex
        )

        if (duplicateIndex !== -1) {
            this.showToast(
                "DUPLICATE FIELD",
                `A field named "${name}" already exists.`,
                "warning"
            )

            this.fieldNameTarget.focus()
            return
        }

        const wasEditing = this.editingIndex !== null

        const field = {
            name,
            label: label || this.humanize(name),
            type,
            description,
            required: this.required,
            multiple: this.multiple,
            active: this.active
        }

        if (!wasEditing) {
            this.fields.push(field)
            this.setActivity(`Added "${field.name}".`)
        } else {
            this.fields[this.editingIndex] = field
            this.setActivity(`Updated "${field.name}".`)
        }

        this.closeFieldEditor()
        this.render()
        this.updateJsonFromFields()

        this.showToast(
            wasEditing ? "FIELD UPDATED" : "FIELD ADDED",
            `"${field.name}" is now part of the definition.`
        )
    }

    editField(event) {
        const index = Number(event.currentTarget.dataset.index)
        const field = this.fields[index]

        if (!field) return

        this.editingIndex = index

        this.fieldEditorTitleTarget.textContent = "Edit definition field"

        this.fieldNameTarget.value = field.name || ""
        this.fieldLabelTarget.value = field.label || ""
        this.fieldTypeTarget.value = field.type || "string"
        this.fieldDescriptionTarget.value = field.description || ""

        this.required = Boolean(field.required)
        this.multiple = Boolean(field.multiple)
        this.active = field.active !== false

        this.refreshToggleUI()

        this.fieldEditorTarget.classList.remove("hidden")
        this.fieldNameTarget.focus()
    }

    deleteField(event) {
        const index = Number(event.currentTarget.dataset.index)
        const field = this.fields[index]

        if (!field) return

        this.fields.splice(index, 1)

        this.render()
        this.updateJsonFromFields()

        this.setActivity(`Removed "${field.name}".`)
        this.showToast(
            "FIELD REMOVED",
            `"${field.name}" was removed from the definition.`
        )
    }

    moveFieldUp(event) {
        const index = Number(event.currentTarget.dataset.index)

        if (index <= 0 || index >= this.fields.length) return

        const [field] = this.fields.splice(index, 1)
        this.fields.splice(index - 1, 0, field)

        this.render()
        this.updateJsonFromFields()
        this.setActivity(`Moved "${field.name}" up.`)
    }

    moveFieldDown(event) {
        const index = Number(event.currentTarget.dataset.index)

        if (index < 0 || index >= this.fields.length - 1) return

        const [field] = this.fields.splice(index, 1)
        this.fields.splice(index + 1, 0, field)

        this.render()
        this.updateJsonFromFields()
        this.setActivity(`Moved "${field.name}" down.`)
    }

    // ---------------------------------------------------------------------------
    // JSON
    // ---------------------------------------------------------------------------

    jsonChanged() {
        const result = this.readJson()

        if (!result.valid) {
            this.jsonValid = false
            this.setJsonError(result.error)
            this.updateStatus()
            return
        }

        const fields = this.normalizeFields(result.value.fields)

        this.jsonValid = true
        this.clearJsonError()

        this.fields = fields
        this.render()

        this.setActivity("Imported changes from JSON.")
        this.updateStatus()
    }

    formatJson() {
        const result = this.readJson()

        if (!result.valid) {
            this.setJsonError(result.error)
            this.jsonTarget.focus()
            return
        }

        this.jsonTarget.value = JSON.stringify(result.value, null, 2)
        this.clearJsonError()

        this.setActivity("JSON formatted.")
        this.showToast(
            "JSON FORMATTED",
            "The definition JSON has been formatted."
        )
    }

    updateJsonFromFields() {
        const definition = {
            fields: this.fields.map((field) => this.serializeField(field))
        }

        this.jsonTarget.value = JSON.stringify(definition, null, 2)

        this.jsonValid = true
        this.clearJsonError()
        this.updateStatus()
    }

    readJson() {
        const raw = this.jsonTarget.value.trim()

        if (!raw) {
            return {
                valid: true,
                value: { fields: [] }
            }
        }

        try {
            const parsed = JSON.parse(raw)

            if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
                return {
                    valid: false,
                    error: "Definition must be a JSON object."
                }
            }

            if (!Array.isArray(parsed.fields)) {
                return {
                    valid: false,
                    error: 'Definition must contain a "fields" array.'
                }
            }

            return {
                valid: true,
                value: parsed
            }
        } catch (error) {
            return {
                valid: false,
                error: error.message || "Invalid JSON."
            }
        }
    }

    normalizeFields(fields) {
        if (!Array.isArray(fields)) return []

        return fields
            .filter((field) => field && typeof field === "object")
            .map((field) => ({
                name: String(field.name || "").trim(),
                label: String(field.label || "").trim(),
                type: String(field.type || "string"),
                description: String(field.description || "").trim(),
                required: Boolean(field.required),
                multiple: Boolean(field.multiple),
                active: field.active !== false
            }))
            .filter((field) => field.name.length > 0)
    }

    serializeField(field) {
        const serialized = {
            name: field.name,
            label: field.label || this.humanize(field.name),
            type: field.type || "string",
            required: Boolean(field.required),
            multiple: Boolean(field.multiple),
            active: field.active !== false
        }

        if (field.description) {
            serialized.description = field.description
        }

        return serialized
    }

    applyLibrary(event) {
        const definition = event.detail?.definition ?? event.detail

        if (!definition) {
            this.showToast(
                "LIBRARY ERROR",
                "The selected definition was empty.",
                "warning"
            )
            return
        }

        let parsed = definition

        if (typeof parsed === "string") {
            try {
                parsed = JSON.parse(parsed)
            } catch (_error) {
                this.showToast(
                    "LIBRARY ERROR",
                    "The selected library definition contains invalid JSON.",
                    "warning"
                )
                return
            }
        }

        if (
            !parsed ||
            typeof parsed !== "object" ||
            Array.isArray(parsed) ||
            !Array.isArray(parsed.fields)
        ) {
            this.showToast(
                "INVALID DEFINITION",
                'Library definitions must contain a "fields" array.',
                "warning"
            )
            return
        }

        this.fields = this.normalizeFields(parsed.fields)
        this.jsonValid = true

        this.render()
        this.updateJsonFromFields()

        this.closeLibraryIfPossible()

        this.setActivity("Loaded a ready definition from the library.")
        this.showToast(
            "DEFINITION LOADED",
            "The ready definition has been imported."
        )
    }

    // ---------------------------------------------------------------------------
    // LIBRARY
    // ---------------------------------------------------------------------------

    openLibrary() {
        const library = this.element.querySelector(
            '[data-controller~="definition-library"]'
        )

        if (!library) {
            this.showToast(
                "LIBRARY UNAVAILABLE",
                "The definition library controller could not be found.",
                "warning"
            )
            return
        }

        const modal = library.querySelector(
            '[data-definition-library-target="modal"]'
        )

        if (modal) {
            modal.classList.remove("hidden")
        }

        window.dispatchEvent(
            new CustomEvent("entity-definition-builder:library-opened")
        )
    }

    closeLibraryIfPossible() {
        const modal = this.element.querySelector(
            '[data-definition-library-target="modal"]'
        )

        if (modal) {
            modal.classList.add("hidden")
        }
    }

    // ---------------------------------------------------------------------------
    // SUBMIT / VALIDATION
    // ---------------------------------------------------------------------------

    beforeSubmit(event) {
        const result = this.readJson()

        if (!result.valid) {
            event.preventDefault()

            this.setJsonError(result.error)
            this.jsonTarget.focus()

            this.showToast(
                "CANNOT CREATE VERSION",
                result.error,
                "warning"
            )

            return
        }

        const fields = this.normalizeFields(result.value.fields)

        const validationError = this.validateFields(fields)

        if (validationError) {
            event.preventDefault()

            this.fields = fields
            this.render()
            this.setJsonError(validationError)

            this.showToast(
                "DEFINITION INVALID",
                validationError,
                "warning"
            )

            return
        }

        // Always normalize the submitted JSON immediately before Rails receives it.
        this.fields = fields
        this.jsonTarget.value = JSON.stringify(
            {
                ...result.value,
                fields: fields.map((field) => this.serializeField(field))
            },
            null,
            2
        )

        this.jsonValid = true
        this.clearJsonError()
        this.updateStatus()

        this.setSubmittingState()
    }

    validateFields(fields) {
        const names = new Set()

        for (const field of fields) {
            if (!field.name) {
                return "Every field must have a name."
            }

            if (!/^[a-zA-Z][a-zA-Z0-9_]*$/.test(field.name)) {
                return `Invalid field name "${field.name}".`
            }

            if (names.has(field.name)) {
                return `Duplicate field name "${field.name}".`
            }

            names.add(field.name)

            if (!field.type) {
                return `Field "${field.name}" must have a data type.`
            }
        }

        return null
    }

    setSubmittingState() {
        if (this.hasSubmitTarget) {
            this.submitTarget.disabled = true
            this.submitTarget.value = "CREATING VERSION..."
            this.submitTarget.classList.add("opacity-70", "cursor-wait")
        }

        if (this.hasHeaderStatusTarget) {
            this.headerStatusTarget.textContent = "CREATING"
        }

        if (this.hasStatusTarget) {
            this.statusTarget.textContent = "Creating version..."
        }
    }

    // ---------------------------------------------------------------------------
    // RENDER
    // ---------------------------------------------------------------------------

    render() {
        this.builderTarget.innerHTML = ""

        this.fields.forEach((field, index) => {
            this.builderTarget.insertAdjacentHTML(
                "beforeend",
                this.fieldHtml(field, index)
            )
        })

        this.updateStatus()
    }

    fieldHtml(field, index) {
        const requiredClass = field.required
            ? "border-orange-200 bg-orange-50/50"
            : "border-slate-100 bg-white"

        const activeClass = field.active
            ? "bg-emerald-50 text-emerald-500"
            : "bg-slate-100 text-slate-400"

        const multipleText = field.multiple ? "Multiple" : "Single"
        const requiredText = field.required ? "Required" : "Optional"
        const activeText = field.active ? "Active" : "Inactive"

        return `
<div
class="rounded-[26px] border-2 ${requiredClass} p-4 shadow-sm transition hover:shadow-md"
data-field-index="${index}">

    <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">

    <div class="flex min-w-0 items-start gap-4">

    <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-violet-50 font-mono text-sm font-black text-violet-500">
    ${index + 1}
</div>

<div class="min-w-0">

    <div class="flex flex-wrap items-center gap-2">

            <span class="font-mono text-sm font-black text-slate-700">
              ${this.escapeHtml(field.name)}
            </span>

        <span class="rounded-full bg-slate-100 px-2 py-1 text-[8px] font-black uppercase tracking-wider text-slate-500">
              ${this.escapeHtml(field.type)}
            </span>

        ${
        field.required
            ? `<span class="rounded-full bg-orange-100 px-2 py-1 text-[8px] font-black uppercase tracking-wider text-orange-500">REQUIRED</span>`
            : ""
    }

    </div>

    <div class="mt-1 text-xs font-bold text-slate-600">
        ${this.escapeHtml(field.label || this.humanize(field.name))}
    </div>

    ${
    field.description
        ? `<div class="mt-1 text-[10px] leading-5 text-slate-400">${this.escapeHtml(field.description)}</div>`
        : ""
}

    <div class="mt-3 flex flex-wrap items-center gap-2">

            <span class="rounded-full bg-slate-100 px-2 py-1 text-[8px] font-black uppercase tracking-wider text-slate-500">
              ${requiredText}
            </span>

        <span class="rounded-full bg-violet-50 px-2 py-1 text-[8px] font-black uppercase tracking-wider text-violet-500">
              ${multipleText}
            </span>

        <span class="rounded-full ${activeClass} px-2 py-1 text-[8px] font-black uppercase tracking-wider">
              ${activeText}
            </span>

    </div>
</div>
</div>

<div class="flex shrink-0 items-center gap-2">

    <button
        type="button"
        title="Move up"
        aria-label="Move field up"
        class="flex h-9 w-9 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-400 transition hover:border-violet-200 hover:text-violet-500 disabled:cursor-not-allowed disabled:opacity-30"
        data-index="${index}"
        data-action="click->entity-definition-builder#moveFieldUp"
        ${index === 0 ? "disabled" : ""}>
        ↑
    </button>

    <button
        type="button"
        title="Move down"
        aria-label="Move field down"
        class="flex h-9 w-9 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-400 transition hover:border-violet-200 hover:text-violet-500 disabled:cursor-not-allowed disabled:opacity-30"
        data-index="${index}"
        data-action="click->entity-definition-builder#moveFieldDown"
        ${index === this.fields.length - 1 ? "disabled" : ""}>
        ↓
    </button>

    <button
        type="button"
        title="Edit field"
        aria-label="Edit field"
        class="rounded-xl border border-violet-100 bg-violet-50 px-3 py-2 text-[8px] font-black uppercase tracking-wider text-violet-500 transition hover:border-violet-300 hover:bg-violet-100"
        data-index="${index}"
        data-action="click->entity-definition-builder#editField">
        EDIT
    </button>

    <button
        type="button"
        title="Delete field"
        aria-label="Delete field"
        class="rounded-xl border border-red-100 bg-red-50 px-3 py-2 text-[8px] font-black uppercase tracking-wider text-red-400 transition hover:border-red-300 hover:bg-red-100"
        data-index="${index}"
        data-action="click->entity-definition-builder#deleteField">
        DELETE
    </button>

</div>
</div>
</div>
`
    }

    // ---------------------------------------------------------------------------
    // STATUS / PROGRESS
    // ---------------------------------------------------------------------------

    updateStatus() {
        const count = this.fields.length
        const required = this.fields.filter((field) => field.required).length
        const active = this.fields.filter((field) => field.active).length

        const health = this.calculateHealth()
        const progress = this.calculateProgress()
        const xp = Math.min(100, progress)

        if (this.hasFieldCountTarget) {
            this.fieldCountTarget.textContent =
                `${count} FIELD${count === 1 ? "" : "S"}`
        }

        if (this.hasSidebarFieldCountTarget) {
            this.sidebarFieldCountTarget.textContent = count
        }

        if (this.hasSidebarRequiredCountTarget) {
            this.sidebarRequiredCountTarget.textContent = required
        }

        if (this.hasSidebarActiveCountTarget) {
            this.sidebarActiveCountTarget.textContent = active
        }

        if (this.hasHealthTarget) {
            this.healthTarget.textContent = `${health}%`
        }

        if (this.hasHealthBarTarget) {
            this.healthBarTarget.style.width = `${health}%`
        }

        if (this.hasProgressLabelTarget) {
            this.progressLabelTarget.textContent = `${progress}%`
        }

        if (this.hasProgressBarTarget) {
            this.progressBarTarget.style.width = `${progress}%`
        }

        if (this.hasXpTarget) {
            this.xpTarget.textContent = xp
        }

        if (this.hasSyncBadgeTarget) {
            this.syncBadgeTarget.textContent =
                this.jsonValid ? "SYNCED" : "OUT OF SYNC"

            this.syncBadgeTarget.classList.toggle(
                "text-emerald-500",
                this.jsonValid
            )

            this.syncBadgeTarget.classList.toggle(
                "text-red-500",
                !this.jsonValid
            )
        }

        const ready = this.jsonValid && !this.validateFields(this.fields)

        if (this.hasSubmitReadinessTarget) {
            this.submitReadinessTarget.classList.toggle("hidden", !ready)
            this.submitReadinessTarget.classList.toggle("flex", ready)
        }

        if (this.hasSidebarStatusTarget) {
            this.sidebarStatusTarget.textContent =
                ready ? "READY" : "CHECK"
        }

        if (this.hasHeaderStatusTarget) {
            this.headerStatusTarget.textContent =
                ready ? "READY" : "CHECK"
        }

        if (this.hasHeaderStatusDotTarget) {
            this.headerStatusDotTarget.classList.toggle(
                "bg-emerald-400",
                ready
            )

            this.headerStatusDotTarget.classList.toggle(
                "bg-orange-400",
                !ready
            )
        }

        if (this.hasStatusDotTarget) {
            this.statusDotTarget.classList.toggle(
                "bg-emerald-400",
                ready
            )

            this.statusDotTarget.classList.toggle(
                "bg-orange-400",
                !ready
            )
        }

        if (this.hasStatusTarget) {
            this.statusTarget.textContent = ready
                ? "Definition builder ready"
                : "Definition needs attention"
        }

        if (this.hasMissionFieldIconTarget) {
            this.missionFieldIconTarget.textContent = count > 0 ? "✓" : "01"

            this.missionFieldIconTarget.classList.toggle(
                "bg-emerald-100",
                count > 0
            )

            this.missionFieldIconTarget.classList.toggle(
                "text-emerald-500",
                count > 0
            )
        }
    }

    calculateProgress() {
        let score = 0

        if (this.fields.length > 0) score += 35
        if (this.fields.some((field) => field.required)) score += 20
        if (this.fields.some((field) => field.description)) score += 15
        if (this.fields.every((field) => field.active)) score += 15
        if (this.jsonValid) score += 15

        return Math.min(100, score)
    }

    calculateHealth() {
        if (!this.jsonValid) return 0

        if (this.fields.length === 0) return 100

        const validFields = this.fields.filter(
            (field) =>
                field.name &&
                /^[a-zA-Z][a-zA-Z0-9_]*$/.test(field.name) &&
                field.type
        ).length

        return Math.round((validFields / this.fields.length) * 100)
    }

    // ---------------------------------------------------------------------------
    // UI HELPERS
    // ---------------------------------------------------------------------------

    setJsonError(message) {
        this.jsonValid = false

        if (this.hasJsonErrorTarget) {
            this.jsonErrorTarget.classList.remove("hidden")
        }

        if (this.hasJsonErrorMessageTarget) {
            this.jsonErrorMessageTarget.textContent = message
        }

        this.updateStatus()
    }

    clearJsonError() {
        this.jsonValid = true

        if (this.hasJsonErrorTarget) {
            this.jsonErrorTarget.classList.add("hidden")
        }

        if (this.hasJsonErrorMessageTarget) {
            this.jsonErrorMessageTarget.textContent = ""
        }
    }

    setActivity(message) {
        if (this.hasActivityTarget) {
            this.activityTarget.textContent = message
        }
    }

    showToast(title, message, type = "success") {
        if (!this.hasToastTarget) return

        this.toastTitleTarget.textContent = title
        this.toastMessageTarget.textContent = message

        const colors = {
            success: {
                icon: "✦",
                text: "text-violet-500",
                bg: "bg-violet-50"
            },
            warning: {
                icon: "⚠",
                text: "text-orange-500",
                bg: "bg-orange-50"
            },
            error: {
                icon: "!",
                text: "text-red-500",
                bg: "bg-red-50"
            }
        }

        const color = colors[type] || colors.success

        this.toastIconTarget.textContent = color.icon

        this.toastIconTarget.className =
            `flex h-10 w-10 items-center justify-center rounded-xl ${color.bg} ${color.text}`

        this.toastTitleTarget.className =
            `text-[9px] font-black uppercase tracking-[0.2em] ${color.text}`

        this.toastTarget.classList.remove("hidden")

        if (this.toastTimer) {
            window.clearTimeout(this.toastTimer)
        }

        this.toastTimer = window.setTimeout(() => {
            this.toastTarget.classList.add("hidden")
        }, 3200)
    }

    humanize(value) {
        return String(value)
            .replace(/[_-]+/g, " ")
            .replace(/\b\w/g, (letter) => letter.toUpperCase())
    }

    escapeHtml(value) {
        return String(value)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;")
    }
}