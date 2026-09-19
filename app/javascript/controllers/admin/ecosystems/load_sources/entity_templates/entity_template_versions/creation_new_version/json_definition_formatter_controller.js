import { Controller } from "@hotwired/stimulus"

/*
 * JSON Definition Formatter
 *
 * Responsibilities:
 * - Parse normal JSON
 * - Repair common JSON syntax mistakes
 * - Normalize entity-definition field names
 * - Resolve duplicate field names
 * - Pretty-print the resulting JSON
 * - Show an audit trail of automatic changes
 * - Dispatch an input event so the existing
 *   entity-definition-builder controller continues
 *   to own validation/synchronization
 *
 * This controller deliberately does NOT replace or modify
 * entity_definition_builder_controller.js.
 */

export default class extends Controller {
  static targets = [
    "input",
    "status",
    "changes",
    "changesList",
    "changeCount"
  ]

  connect() {
    this.lastFormattedValue = null
    this.maxRepairPasses = 3

    this.setStatus(
      "READY",
      "border-emerald-500/20 bg-emerald-500/10 text-emerald-400"
    )

    this.renderChanges([])
  }

  format() {
    const source = this.inputTarget.value

    if (!source.trim()) {
      this.showFailure(
        "There is no JSON to format.",
        "Enter a definition first, then try again."
      )
      return
    }

    try {
      const result = this.process(source)

      this.inputTarget.value = result.json
      this.lastFormattedValue = result.json

      /*
       * Important:
       *
       * We dispatch a real input event instead of directly calling
       * methods on the existing builder controller.
       *
       * This preserves the existing architecture:
       *
       * JSON editor
       *      ↓
       * input event
       *      ↓
       * entity-definition-builder#jsonChanged
       *      ↓
       * existing validation/synchronization
       */
      this.dispatchInputEvent()

      this.renderChanges(result.changes)

      if (result.changes.length > 0) {
        this.setStatus(
          "AUTO-CORRECTED",
          "border-amber-500/20 bg-amber-500/10 text-amber-300"
        )
      } else {
        this.setStatus(
          "FORMATTED",
          "border-emerald-500/20 bg-emerald-500/10 text-emerald-400"
        )
      }

      this.scrollChangesIntoView()
    } catch (error) {
      this.showFailure(
        "JSON could not be repaired safely.",
        error.message
      )
    }
  }

  process(source) {
    const changes = []

    let parsed

    /*
     * Phase 1:
     * Try completely standard JSON first.
     */
    try {
      parsed = JSON.parse(source)
    } catch (_error) {
      /*
       * Phase 2:
       * Repair only well-understood syntax problems.
       */
      const repaired = this.repairCommonJsonSyntax(source)

      if (repaired.value === source) {
        throw new Error(
          "The JSON contains a syntax error that could not be repaired automatically."
        )
      }

      changes.push(...repaired.changes)

      try {
        parsed = JSON.parse(repaired.value)
      } catch (_error) {
        throw new Error(
          "The JSON was partially repaired, but it is still not valid JSON. Review the highlighted structure and correct the remaining syntax manually."
        )
      }
    }

    /*
     * Phase 3:
     * Normalize the entity-definition structure.
     *
     * This is intentionally conservative.
     * We only modify structures that look like:
     *
     * {
     *   "fields": [...]
     * }
     */
    const normalized = this.normalizeDefinition(parsed)

    changes.push(...normalized.changes)

    parsed = normalized.value

    /*
     * Phase 4:
     * Final JSON validation.
     */
    const json = JSON.stringify(parsed, null, 2)

    try {
      JSON.parse(json)
    } catch (_error) {
      throw new Error(
        "The formatter generated an invalid result. No changes were applied."
      )
    }

    return {
      json,
      changes
    }
  }

  repairCommonJsonSyntax(source) {
    let value = source
    const changes = []

    /*
     * Normalize smart quotes first.
     */
    const smartQuotes = value

    value = value
      .replace(/[“”]/g, '"')
      .replace(/[‘’]/g, "'")

    if (value !== smartQuotes) {
      changes.push({
        type: "syntax",
        title: "Normalized smart quotes",
        description:
          "Converted curly quotation marks to standard JSON quotation marks."
      })
    }

    /*
     * Remove UTF-8 BOM if present.
     */
    if (value.charCodeAt(0) === 0xfeff) {
      value = value.slice(1)

      changes.push({
        type: "syntax",
        title: "Removed invisible BOM",
        description:
          "Removed an invisible Unicode byte-order mark from the beginning of the JSON."
      })
    }

    /*
     * Convert single-quoted JSON strings into double-quoted strings.
     *
     * This deliberately handles common simple strings rather than
     * attempting to interpret arbitrary JavaScript expressions.
     */
    const singleQuoteResult = this.convertSimpleSingleQuotedStrings(value)

    if (singleQuoteResult.value !== value) {
      value = singleQuoteResult.value

      changes.push({
        type: "syntax",
        title: "Converted single quotes",
        description:
          "Converted simple single-quoted JSON strings to standard double-quoted strings."
      })
    }

    /*
     * Quote simple unquoted property names:
     *
     * name: "John"
     *
     * becomes:
     *
     * "name": "John"
     */
    const unquotedKeys = value

    value = value.replace(
      /([{,]\s*)([A-Za-z_$][A-Za-z0-9_$-]*)(\s*:)/g,
      '$1"$2"$3'
    )

    if (value !== unquotedKeys) {
      changes.push({
        type: "syntax",
        title: "Quoted property names",
        description:
          "Added JSON quotation marks around simple unquoted property names."
      })
    }

    /*
     * Remove trailing commas:
     *
     * {
     *   "name": "John",
     * }
     */
    const trailingCommas = value

    value = value.replace(/,\s*([}\]])/g, "$1")

    if (value !== trailingCommas) {
      changes.push({
        type: "syntax",
        title: "Removed trailing commas",
        description:
          "Removed commas appearing immediately before closing objects or arrays."
      })
    }

    /*
     * Normalize repeated passes because one repair can expose
     * another simple repair opportunity.
     */
    for (let pass = 1; pass < this.maxRepairPasses; pass += 1) {
      let changed = false

      const next = value.replace(/,\s*([}\]])/g, "$1")

      if (next !== value) {
        value = next
        changed = true
      }

      if (!changed) {
        break
      }
    }

    return {
      value,
      changes
    }
  }

  convertSimpleSingleQuotedStrings(value) {
    let result = ""
    let changed = false
    let insideDouble = false
    let insideSingle = false

    for (let index = 0; index < value.length; index += 1) {
      const char = value[index]
      const previous = value[index - 1]

      if (char === '"' && previous !== "\\") {
        insideDouble = !insideDouble
        result += char
        continue
      }

      if (char === "'" && previous !== "\\" && !insideDouble) {
        insideSingle = !insideSingle
        result += '"'
        changed = true
        continue
      }

      if (insideSingle && char === '"' && previous !== "\\") {
        result += '\\"'
        changed = true
        continue
      }

      result += char
    }

    /*
     * If the source contained an unmatched single quote, do not
     * pretend that we successfully repaired it.
     */
    if (insideSingle) {
      return {
        value,
        changed: false
      }
    }

    return {
      value: changed ? result : value,
      changed
    }
  }

  normalizeDefinition(value) {
    const changes = []

    if (!value || typeof value !== "object" || Array.isArray(value)) {
      return {
        value,
        changes
      }
    }

    if (!Array.isArray(value.fields)) {
      return {
        value,
        changes
      }
    }

    const usedNames = new Set()

    value.fields = value.fields.map((field, index) => {
      if (!field || typeof field !== "object" || Array.isArray(field)) {
        return field
      }

      const originalName =
        typeof field.name === "string"
          ? field.name
          : ""

      if (!originalName.trim()) {
        const generatedName = this.generateFieldName(
          field.label,
          index,
          usedNames
        )

        field.name = generatedName
        usedNames.add(generatedName)

        changes.push({
          type: "structure",
          title: `Generated field name for field ${index + 1}`,
          description:
            `The field did not have a usable name. Generated "${generatedName}".`,
          before: originalName || "(empty)",
          after: generatedName
        })

        return field
      }

      const normalizedName = this.normalizeFieldName(
        originalName,
        field.label,
        index,
        usedNames
      )

      if (normalizedName !== originalName) {
        field.name = normalizedName

        changes.push({
          type: "structure",
          title: "Normalized field name",
          description:
            "Converted the field name into a builder-safe identifier.",
          before: originalName,
          after: normalizedName
        })
      }

      usedNames.add(normalizedName)

      return field
    })

    return {
      value,
      changes
    }
  }

  normalizeFieldName(originalName, label, index, usedNames) {
    let candidate = originalName
      .normalize("NFKD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[^A-Za-z0-9_]+/g, "_")
      .replace(/^_+|_+$/g, "")
      .replace(/_+/g, "_")
      .toLowerCase()

    /*
     * Prefer the existing name.
     *
     * If normalization removed everything, use the label.
     */
    if (!candidate && label) {
      candidate = String(label)
        .normalize("NFKD")
        .replace(/[\u0300-\u036f]/g, "")
        .replace(/[^A-Za-z0-9_]+/g, "_")
        .replace(/^_+|_+$/g, "")
        .replace(/_+/g, "_")
        .toLowerCase()
    }

    if (!candidate) {
      candidate = `field_${index + 1}`
    }

    /*
     * Avoid identifiers beginning with a digit.
     */
    if (/^\d/.test(candidate)) {
      candidate = `field_${candidate}`
    }

    /*
     * Avoid reserved-looking empty/invalid identifiers.
     */
    if (!candidate) {
      candidate = `field_${index + 1}`
    }

    /*
     * Make duplicates unique.
     */
    const base = candidate
    let counter = 2

    while (usedNames.has(candidate)) {
      candidate = `${base}_${counter}`
      counter += 1
    }

    return candidate
  }

  generateFieldName(label, index, usedNames) {
    return this.normalizeFieldName(
      label || "",
      label || "",
      index,
      usedNames
    )
  }

  dispatchInputEvent() {
    this.inputTarget.dispatchEvent(
      new Event("input", {
        bubbles: true
      })
    )
  }

  renderChanges(changes) {
    if (!this.hasChangesTarget) {
      return
    }

    if (!changes || changes.length === 0) {
      this.changesTarget.classList.add("hidden")

      if (this.hasChangeCountTarget) {
        this.changeCountTarget.textContent = "0 changes"
      }

      if (this.hasChangesListTarget) {
        this.changesListTarget.innerHTML = ""
      }

      return
    }

    this.changesTarget.classList.remove("hidden")

    if (this.hasChangeCountTarget) {
      this.changeCountTarget.textContent =
        `${changes.length} ${changes.length === 1 ? "change" : "changes"}`
    }

    if (this.hasChangesListTarget) {
      this.changesListTarget.innerHTML = changes
        .map((change) => this.renderChange(change))
        .join("")
    }
  }

  renderChange(change) {
    const before = change.before
      ? `<div class="mt-2 rounded-lg bg-red-50 px-3 py-2 font-mono text-xs text-red-700 break-all">
    <span class="font-bold">Before:</span>
${this.escapeHtml(change.before)}
</div>`
      : ""

    const after = change.after
      ? `<div class="mt-2 rounded-lg bg-emerald-50 px-3 py-2 font-mono text-xs text-emerald-700 break-all">
    <span class="font-bold">After:</span>
${this.escapeHtml(change.after)}
</div>`
      : ""

    return `
<div class="rounded-xl border border-slate-200 bg-white p-4 shadow-sm">
    <div class="flex items-start gap-3">
    <span class="mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-amber-100 text-sm font-black text-amber-700">
            ✓
</span>

<div class="min-w-0">
    <div class="text-sm font-bold text-slate-800">
        ${this.escapeHtml(change.title)}
    </div>

    <div class="mt-1 text-xs leading-5 text-slate-600">
        ${this.escapeHtml(change.description)}
    </div>

    ${before}
    ${after}
</div>
</div>
</div>
`
  }

  showFailure(title, description) {
    this.setStatus(
      "NEEDS ATTENTION",
      "border-red-500/20 bg-red-500/10 text-red-300"
    )

    this.renderChanges([
      {
        type: "error",
        title,
        description
      }
    ])
  }

  setStatus(text, classes) {
    if (!this.hasStatusTarget) {
      return
    }

    this.statusTarget.className =
      `rounded-full border px-3 py-1.5 text-xs font-black uppercase tracking-wider ${classes}`

    this.statusTarget.textContent = text
  }

  scrollChangesIntoView() {
    if (!this.hasChangesTarget) {
      return
    }

    window.setTimeout(() => {
      this.changesTarget.scrollIntoView({
        behavior: "smooth",
        block: "nearest"
      })
    }, 50)
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