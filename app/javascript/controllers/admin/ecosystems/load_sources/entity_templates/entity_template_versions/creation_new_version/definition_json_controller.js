import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "input",
        "status",
        "error",
        "errorMessage"
    ]

    connect() {
        this.lastValidObject = null
        this.validationTimer = null

        this.validate(false)
    }

    changed() {
        clearTimeout(this.validationTimer)

        this.setWorkingState()

        this.validationTimer = setTimeout(() => {
            this.validate(true)
        }, 250)
    }

    validate(emit = true) {
        const raw = this.inputTarget.value.trim()

        if (!raw) {
            this.setInvalid("Definition cannot be empty.")
            return false
        }

        try {
            const parsed = JSON.parse(raw)

            const structuralError = this.validateStructure(parsed)

            if (structuralError) {
                this.setInvalid(structuralError)
                return false
            }

            this.lastValidObject = parsed
            this.setValid()

            if (emit) {
                this.dispatch("valid", {
                    detail: {
                        definition: parsed,
                        source: "json"
                    }
                })
            }

            return true
        } catch (error) {
            const repaired = this.trySafeRepair(raw)

            if (repaired) {
                try {
                    const parsed = JSON.parse(repaired)

                    const structuralError = this.validateStructure(parsed)

                    if (!structuralError) {
                        this.inputTarget.value = JSON.stringify(parsed, null, 2)
                        this.lastValidObject = parsed
                        this.setValid("AUTO-REPAIRED")

                        if (emit) {
                            this.dispatch("valid", {
                                detail: {
                                    definition: parsed,
                                    source: "json-repaired"
                                }
                            })
                        }

                        return true
                    }
                } catch (_) {
                    // Continue to normal invalid state.
                }
            }

            this.setInvalid(this.formatSyntaxError(error, raw))
            return false
        }
    }

    format() {
        try {
            const parsed = JSON.parse(this.inputTarget.value)

            const structuralError = this.validateStructure(parsed)

            if (structuralError) {
                this.setInvalid(structuralError)
                return false
            }

            this.inputTarget.value = JSON.stringify(parsed, null, 2)

            this.setValid("FORMATTED")

            this.dispatch("formatted", {
                detail: {
                    definition: parsed
                }
            })

            return true
        } catch (error) {
            this.setInvalid(this.formatSyntaxError(error, this.inputTarget.value))
            return false
        }
    }

    setFromObject(object) {
        this.inputTarget.value = JSON.stringify(object, null, 2)
        this.lastValidObject = object
        this.setValid()

        this.dispatch("valid", {
            detail: {
                definition: object,
                source: "builder"
            }
        })
    }

    getObject() {
        try {
            return JSON.parse(this.inputTarget.value)
        } catch (_) {
            return null
        }
    }

    validateStructure(definition) {
        if (!definition || typeof definition !== "object" || Array.isArray(definition)) {
            return "Definition root must be a JSON object."
        }

        if (!Array.isArray(definition.fields)) {
            return 'Definition must contain a "fields" array.'
        }

        const names = new Set()

        for (let index = 0; index < definition.fields.length; index++) {
            const field = definition.fields[index]

            if (!field || typeof field !== "object" || Array.isArray(field)) {
                return `Field ${index + 1} must be a JSON object.`
            }

            if (!field.name || typeof field.name !== "string") {
                return `Field ${index + 1} must contain a string "name".`
            }

            if (!/^[a-zA-Z][a-zA-Z0-9_]*$/.test(field.name)) {
                return `Field "${field.name}" has an invalid name. Use letters, numbers and underscores.`
            }

            if (names.has(field.name)) {
                return `Duplicate field name "${field.name}".`
            }

            names.add(field.name)

            if (!field.type || typeof field.type !== "string") {
                return `Field "${field.name}" must contain a "type".`
            }

            const allowedTypes = [
                "string",
                "text",
                "integer",
                "number",
                "boolean",
                "date",
                "datetime",
                "email",
                "url",
                "json"
            ]

            if (!allowedTypes.includes(field.type)) {
                return `Field "${field.name}" uses unsupported type "${field.type}".`
            }

            if ("required" in field && typeof field.required !== "boolean") {
                return `Field "${field.name}" has an invalid "required" value.`
            }

            if ("multiple" in field && typeof field.multiple !== "boolean") {
                return `Field "${field.name}" has an invalid "multiple" value.`
            }

            if ("active" in field && typeof field.active !== "boolean") {
                return `Field "${field.name}" has an invalid "active" value.`
            }
        }

        return null
    }

    trySafeRepair(raw) {
        let repaired = raw

        // Smart quotes -> normal quotes.
        repaired = repaired
            .replace(/[“”]/g, '"')
            .replace(/[‘’]/g, "'")

        // Remove trailing commas before } or ].
        repaired = repaired.replace(/,\s*([}\]])/g, "$1")

        if (repaired === raw) {
            return null
        }

        return repaired
    }

    formatSyntaxError(error, raw) {
        let message = error?.message || "Invalid JSON."

        const positionMatch = message.match(/position\s+(\d+)/i)

        if (positionMatch) {
            const position = Number(positionMatch[1])
            const before = raw.slice(0, position)
            const line = before.split("\n").length
            const column = position - before.lastIndexOf("\n")

            message = `${message} Line ${line}, column ${column}.`
        }

        return message
    }

    setWorkingState() {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent = "CHECKING..."
            this.statusTarget.className =
                "rounded-full border border-amber-500/20 bg-amber-500/10 px-3 py-1.5 text-[8px] font-black uppercase tracking-wider text-amber-400"
        }

        this.hideError()
    }

    setValid(label = "VALID JSON") {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent = label
            this.statusTarget.className =
                "rounded-full border border-emerald-500/20 bg-emerald-500/10 px-3 py-1.5 text-[8px] font-black uppercase tracking-wider text-emerald-400"
        }

        this.hideError()
    }

    setInvalid(message) {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent = "INVALID JSON"
            this.statusTarget.className =
                "rounded-full border border-red-500/20 bg-red-500/10 px-3 py-1.5 text-[8px] font-black uppercase tracking-wider text-red-400"
        }

        if (this.hasErrorTarget) {
            this.errorTarget.classList.remove("hidden")
        }

        if (this.hasErrorMessageTarget) {
            this.errorMessageTarget.textContent = message
        }

        this.dispatch("invalid", {
            detail: {
                message
            }
        })
    }

    hideError() {
        if (this.hasErrorTarget) {
            this.errorTarget.classList.add("hidden")
        }
    }
}