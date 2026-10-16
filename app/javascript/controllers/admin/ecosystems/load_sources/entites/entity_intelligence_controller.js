import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "status",
        "relationships",
        "signals",
        "discoverButton"
    ]

    static values = {
        relationshipsUrl: String,
        intelligenceUrl: String
    }

    connect() {
        this.loadIntelligence()
    }

    async loadIntelligence() {
        this.setStatus("Loading intelligence…")

        try {
            const response = await fetch(this.intelligenceUrlValue, {
                headers: {
                    Accept: "application/json"
                }
            })

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`)
            }

            const data = await response.json()

            this.renderSignals(data.signals || [])
            this.renderRelationships(
                data.relationships?.relationships || []
            )

            this.setStatus("Intelligence ready")
        } catch (error) {
            console.error(
                "Entity intelligence failed:",
                error
            )

            this.setStatus(
                "Unable to load intelligence"
            )
        }
    }

    async discover() {
        if (!this.hasDiscoverButtonTarget) return

        this.discoverButtonTarget.disabled = true
        this.setStatus("Discovering relationships…")

        try {
            const response = await fetch(
                this.relationshipsUrlValue,
                {
                    method: "POST",
                    headers: {
                        Accept: "application/json",
                        "X-CSRF-Token": this.csrfToken()
                    }
                }
            )

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`)
            }

            await response.json()

            await this.loadIntelligence()
        } catch (error) {
            console.error(
                "Relationship discovery failed:",
                error
            )

            this.setStatus(
                "Relationship discovery failed"
            )
        } finally {
            this.discoverButtonTarget.disabled = false
        }
    }

    renderRelationships(relationships) {
        if (!this.hasRelationshipsTarget) return

        if (relationships.length === 0) {
            this.relationshipsTarget.innerHTML = `
        <div class="rounded-xl border border-dashed border-gray-300 p-4 text-xs text-gray-400">
          No relationships discovered yet.
        </div>
      `

            return
        }

        this.relationshipsTarget.innerHTML =
            relationships
                .map((relationship) => {
                    const confidence =
                        Number(
                            relationship.confidence_percent || 0
                        )

                    return `
            <div class="rounded-xl border border-gray-200 bg-white p-3 dark:border-gray-800 dark:bg-gray-950">
              <div class="flex items-start justify-between gap-3">
                <div class="min-w-0">
                  <div class="truncate text-xs font-black text-gray-800 dark:text-white">
                    ${this.escape(
                        relationship.entity_name || "Unknown"
                    )}
                  </div>

                  <div class="mt-1 text-[9px] font-bold uppercase tracking-wider text-indigo-500">
                    ${this.escape(
                        relationship.label || relationship.kind || "Related"
                    )}
                  </div>
                </div>

                <div class="shrink-0 text-[10px] font-black text-emerald-500">
                  ${confidence}%
                </div>
              </div>

              <div class="mt-3 h-1.5 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800">
                <div
                  class="h-full rounded-full bg-gradient-to-r from-indigo-500 to-emerald-500"
                  style="width: ${confidence}%">
                </div>
              </div>
            </div>
          `
                })
                .join("")
    }

    renderSignals(signals) {
        if (!this.hasSignalsTarget) return

        if (signals.length === 0) {
            this.signalsTarget.innerHTML = `
        <div class="text-xs text-gray-400">
          No intelligence signals.
        </div>
      `

            return
        }

        this.signalsTarget.innerHTML =
            signals
                .map((signal) => {
                    return `
            <div class="rounded-xl border border-indigo-100 bg-indigo-50/60 p-3 dark:border-indigo-900 dark:bg-indigo-950/30">
              <div class="text-xs font-black text-indigo-700 dark:text-indigo-300">
                ${this.escape(signal.title)}
              </div>

              <div class="mt-1 text-[11px] leading-relaxed text-gray-500 dark:text-gray-400">
                ${this.escape(signal.description)}
              </div>
            </div>
          `
                })
                .join("")
    }

    setStatus(message) {
        if (!this.hasStatusTarget) return

        this.statusTarget.textContent = message
    }

    csrfToken() {
        return document
            .querySelector('meta[name="csrf-token"]')
            ?.content
    }

    escape(value) {
        const element =
            document.createElement("div")

        element.textContent =
            String(value ?? "")

        return element.innerHTML
    }
}