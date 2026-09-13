import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        index: Number
    }

    static targets = [
        "name",
        "label",
        "type",
        "description",
        "requiredIcon",
        "requiredLabel",
        "multipleIcon",
        "multipleLabel",
        "activeIcon",
        "activeLabel"
    ]

    connect() {
        this.required = false
        this.multiple = false
        this.active = true

        this.render()
    }

    toggleRequired() {
        this.required = !this.required
        this.render()

        this.dispatch("changed", {
            detail: {
                action: "field-option-changed"
            }
        })
    }

    toggleMultiple() {
        this.multiple = !this.multiple
        this.render()

        this.dispatch("changed", {
            detail: {
                action: "field-option-changed"
            }
        })
    }

    toggleActive() {
        this.active = !this.active
        this.render()

        this.dispatch("changed", {
            detail: {
                action: "field-option-changed"
            }
        })
    }

    remove() {
        this.dispatch("remove", {
            detail: {
                index: this.indexValue
            }
        })

        this.element.remove()
    }

    edit() {
        this.dispatch("edit", {
            detail: {
                index: this.indexValue,
                field: this.toObject()
            }
        })
    }

    moveUp() {
        this.dispatch("move", {
            detail: {
                index: this.indexValue,
                direction: -1
            }
        })
    }

    moveDown() {
        this.dispatch("move", {
            detail: {
                index: this.indexValue,
                direction: 1
            }
        })
    }

    toObject() {
        return {
            name: this.nameTarget.value.trim(),
            label: this.labelTarget.value.trim(),
            type: this.typeTarget.value,
            description: this.descriptionTarget.value.trim(),
            required: this.required,
            multiple: this.multiple,
            active: this.active
        }
    }

    load(field) {
        this.nameTarget.value = field.name || ""
        this.labelTarget.value = field.label || ""
        this.typeTarget.value = field.type || "string"
        this.descriptionTarget.value = field.description || ""

        this.required = Boolean(field.required)
        this.multiple = Boolean(field.multiple)
        this.active = field.active !== false

        this.render()
    }

    render() {
        if (this.hasRequiredIconTarget) {
            this.requiredIconTarget.textContent = this.required ? "✓" : "○"
            this.requiredIconTarget.className = this.required
                ? "flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-100 text-emerald-500"
                : "flex h-8 w-8 items-center justify-center rounded-xl bg-slate-50 text-slate-300"
        }

        if (this.hasRequiredLabelTarget) {
            this.requiredLabelTarget.textContent =
                this.required ? "Required" : "Optional"
        }

        if (this.hasMultipleIconTarget) {
            this.multipleIconTarget.textContent = this.multiple ? "✓" : "○"
            this.multipleIconTarget.className = this.multiple
                ? "flex h-8 w-8 items-center justify-center rounded-xl bg-violet-100 text-violet-500"
                : "flex h-8 w-8 items-center justify-center rounded-xl bg-slate-50 text-slate-300"
        }

        if (this.hasMultipleLabelTarget) {
            this.multipleLabelTarget.textContent =
                this.multiple ? "Multiple values" : "Single"
        }

        if (this.hasActiveIconTarget) {
            this.activeIconTarget.textContent = this.active ? "●" : "○"
            this.activeIconTarget.className = this.active
                ? "flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-50 text-emerald-400"
                : "flex h-8 w-8 items-center justify-center rounded-xl bg-slate-50 text-slate-300"
        }

        if (this.hasActiveLabelTarget) {
            this.activeLabelTarget.textContent =
                this.active ? "Enabled" : "Disabled"
        }
    }
}