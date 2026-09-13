import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "template",
        "version",
        "versionHelp",
        "versionBadge"
    ]

    static values = {
        templates: Object
    }

    connect() {
        this.refreshVersions()
    }

    templateChanged() {
        this.refreshVersions()
    }

    refreshVersions() {
        const templateId = this.templateTarget.value

        this.clearVersions()

        if (!templateId) {
            this.disableVersionSelect()
            this.setHelpText("Select an entity template first.")
            this.setBadge("WAITING")
            return
        }

        const template = this.templatesValue[templateId]

        if (!template) {
            this.disableVersionSelect()
            this.setHelpText("No template information is available.")
            this.setBadge("UNAVAILABLE")
            return
        }

        const versions = Array.isArray(template.versions)
            ? template.versions
            : []

        if (versions.length === 0) {
            this.disableVersionSelect()
            this.setHelpText("This template does not have any versions yet.")
            this.setBadge("NO VERSIONS")
            return
        }

        versions.forEach((version) => {
            const option = document.createElement("option")

            option.value = version.id
            option.textContent = this.versionLabel(version)

            option.classList.add("bg-white", "text-slate-700")

            this.versionTarget.appendChild(option)
        })

        this.enableVersionSelect()

        this.setHelpText(
            `${versions.length} template version${versions.length === 1 ? "" : "s"} available.`
        )

        this.setBadge(`${versions.length} AVAILABLE`)
    }

    versionChanged() {
        const selectedOption =
            this.versionTarget.options[this.versionTarget.selectedIndex]

        if (!this.versionTarget.value || !selectedOption) {
            this.setBadge("SELECT VERSION")
            return
        }

        this.setBadge("SELECTED")
    }

    versionLabel(version) {
        const versionNumber =
            version.version !== null && version.version !== undefined
                ? `v${version.version}`
                : `Version ${version.id}`

        const status =
            version.status
                ? ` — ${String(version.status).toUpperCase()}`
                : ""

        return `${versionNumber}${status}`
    }

    clearVersions() {
        this.versionTarget.innerHTML = ""

        const placeholder = document.createElement("option")

        placeholder.value = ""
        placeholder.textContent = "Select template version..."
        placeholder.selected = true

        placeholder.classList.add("bg-white", "text-slate-400")

        this.versionTarget.appendChild(placeholder)
    }

    disableVersionSelect() {
        this.versionTarget.disabled = true

        this.versionTarget.classList.remove(
            "border-violet-300",
            "bg-white",
            "text-slate-700"
        )

        this.versionTarget.classList.add(
            "border-slate-200",
            "bg-slate-100",
            "text-slate-400",
            "cursor-not-allowed"
        )
    }

    enableVersionSelect() {
        this.versionTarget.disabled = false

        this.versionTarget.classList.remove(
            "border-slate-200",
            "bg-slate-100",
            "text-slate-400",
            "cursor-not-allowed"
        )

        this.versionTarget.classList.add(
            "border-violet-300",
            "bg-white",
            "text-slate-700"
        )
    }

    setHelpText(text) {
        if (this.hasVersionHelpTarget) {
            this.versionHelpTarget.textContent = text
        }
    }

    setBadge(text) {
        if (this.hasVersionBadgeTarget) {
            this.versionBadgeTarget.textContent = text
        }
    }
}