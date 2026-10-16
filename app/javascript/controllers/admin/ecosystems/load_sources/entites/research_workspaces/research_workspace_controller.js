import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["recommendations"]

    static values = {
        recommendationsUrl: String
    }

    connect() {
        this.refreshTimer = null
    }

    disconnect() {
        if (this.refreshTimer) {
            clearTimeout(this.refreshTimer)
        }
    }

    async refreshRecommendations(event) {
        if (event) {
            event.preventDefault()
        }

        if (!this.hasRecommendationsTarget) {
            return
        }

        this.recommendationsTarget.classList.add("opacity-60")

        try {
            const response = await fetch(this.recommendationsUrlValue, {
                headers: {
                    "Accept": "application/json"
                },
                credentials: "same-origin"
            })

            if (!response.ok) {
                throw new Error(`Recommendation request failed: ${response.status}`)
            }

            const data = await response.json()

            this.renderRecommendations(data.recommendations || [])
        } catch (error) {
            console.error("Research workspace intelligence:", error)
        } finally {
            this.recommendationsTarget.classList.remove("opacity-60")
        }
    }

    renderRecommendations(recommendations) {
        const existing = this.recommendationsTarget.querySelector(
            "[data-recommendation-list]"
        )

        if (!existing) {
            return
        }

        existing.innerHTML = ""

        if (recommendations.length === 0) {
            existing.innerHTML = `
        <div class="rounded-2xl bg-white/5 p-4 text-sm text-slate-500">
          No recommendations yet.
        </div>
      `

            return
        }

        recommendations.forEach((recommendation) => {
            const wrapper = document.createElement("div")

            wrapper.className =
                "rounded-2xl border border-white/10 bg-black/10 p-4"

            wrapper.innerHTML = `
        <div class="flex items-start gap-3">
          <div class="text-lg">
            ${this.iconFor(recommendation.kind)}
          </div>

          <div class="min-w-0 flex-1">
            <div class="font-bold">
              ${this.escapeHtml(recommendation.title)}
            </div>

            <div class="mt-1 text-xs leading-5 text-slate-500">
              ${this.escapeHtml(recommendation.description)}
            </div>
          </div>
        </div>
      `

            existing.appendChild(wrapper)
        })
    }

    iconFor(kind) {
        const icons = {
            entity: "🧩",
            relationship: "🔗",
            question: "❓",
            note: "📝",
            evidence: "🔎",
            milestone: "🎯",
            recommendation: "✦"
        }

        return icons[kind] || "🧭"
    }

    escapeHtml(value) {
        const div = document.createElement("div")
        div.textContent = value ?? ""
        return div.innerHTML
    }
}