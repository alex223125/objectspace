
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["oldVersion", "newVersion", "status", "submit"]

    static values = {
        oldParam: { type: String, default: "old_version_id" },
        newParam: { type: String, default: "new_version_id" },
        updateUrl: { type: Boolean, default: true }
    }

    connect() {
        this.validate()
    }

    change() {
        const valid = this.validate()

        if (!valid) return

        this.dispatch("changed", {
            detail: {
                oldVersionId: this.selectedOldVersion,
                newVersionId: this.selectedNewVersion
            }
        })

        if (this.updateUrlValue) {
            this.updateUrl()
        }
    }

    validate() {
        const oldId = this.selectedOldVersion
        const newId = this.selectedNewVersion

        const bothSelected = Boolean(oldId && newId)
        const distinct = !bothSelected || oldId !== newId
        const valid = bothSelected && distinct

        if (this.hasSubmitTarget) {
            this.submitTarget.disabled = !valid
        }

        if (this.hasStatusTarget) {
            if (!oldId || !newId) {
                this.statusTarget.textContent = "Select both revisions to compare."
            } else if (!distinct) {
                this.statusTarget.textContent =
                    "Choose two different revisions for a meaningful comparison."
            } else {
                this.statusTarget.textContent =
                    "Both revisions are selected and ready to compare."
            }
        }

        return valid
    }

    updateUrl() {
        const url = new URL(window.location.href)

        url.searchParams.set(this.oldParamValue, this.selectedOldVersion)
        url.searchParams.set(this.newParamValue, this.selectedNewVersion)

        window.history.replaceState({}, "", url)
    }

    get selectedOldVersion() {
        return this.hasOldVersionTarget
            ? this.oldVersionTarget.value
            : ""
    }

    get selectedNewVersion() {
        return this.hasNewVersionTarget
            ? this.newVersionTarget.value
            : ""
    }

    swap(event) {
        event?.preventDefault()

        if (!this.hasOldVersionTarget || !this.hasNewVersionTarget) return

        const oldId = this.oldVersionTarget.value
        this.oldVersionTarget.value = this.newVersionTarget.value
        this.newVersionTarget.value = oldId

        this.change()
    }
}