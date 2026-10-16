import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "xp",
        "score",
        "recommendationCount",
        "signalCount",
        "missionCount",
        "currentEntity",
        "signals",
        "recommendations",
        "missions",
        "missionXp",
        "error"
    ]

    static values = {
        url: String,
        recommendationsUrl: String,
        missionsUrl: String
    }

    connect() {
        this.currentEntityId = null
        this.currentEntityType = null

        this.listenForGraphSelection()
    }

    disconnect() {
        if (this.graphHandler) {
            window.removeEventListener("ecosystem:node-selected", this.graphHandler)
        }
    }

    listenForGraphSelection() {
        this.graphHandler = (event) => {
            const detail = event.detail || {}

            if (!detail.id) return

            this.selectEntity({
                id: detail.id,
                type: detail.type,
                name: detail.name
            })
        }

        window.addEventListener(
            "ecosystem:node-selected",
            this.graphHandler
        )
    }

    async selectEntity(entity) {
        this.currentEntityId = entity.id
        this.currentEntityType = entity.type || "Entity"

        this.currentEntityTarget.textContent =
            entity.name || `Entity #${entity.id}`

        this.clearError()

        await this.loadDiscovery()
    }

    async refresh() {
        if (!this.currentEntityId) return

        await this.loadDiscovery()
    }

    async loadDiscovery() {
        this.showLoading()

        const url = new URL(this.urlValue, window.location.origin)

        url.searchParams.set("entity_id", this.currentEntityId)

        if (this.currentEntityType) {
            url.searchParams.set(
                "entity_type",
                this.currentEntityType
            )
        }

        try {
            const response = await fetch(url.toString(), {
                headers: {
                    Accept: "application/json"
                }
            })

            if (!response.ok) {
                throw new Error(`Discovery request failed: ${response.status}`)
            }

            const data = await response.json()

            this.render(data)
        } catch (error) {
            console.error(error)

            this.showError(
                "The discovery engine could not load this ecosystem path."
            )
        }
    }

    render(data) {
        const metrics = data.metrics || {}

        this.xpTarget.textContent =
            metrics.explorer_xp_available || 0

        this.scoreTarget.textContent =
            metrics.discovery_score || 0

        this.recommendationCountTarget.textContent =
            metrics.recommendation_count || 0

        this.signalCountTarget.textContent =
            metrics.signal_count || 0

        this.missionCountTarget.textContent =
            metrics.mission_count || 0

        this.renderSignals(data.signals || [])
        this.renderRecommendations(data.recommendations || [])
        this.renderMissions(data.missions || [])

        const missionXp = (data.missions || [])
            .reduce(
                (sum, mission) => sum + Number(mission.reward || 0),
                0
            )

        this.missionXpTarget.textContent = missionXp
    }

    renderSignals(signals) {
        if (!signals.length) {
            this.signalsTarget.innerHTML = this.emptyState(
                "No significant signals detected yet."
            )

            return
        }

        this.signalsTarget.innerHTML = signals
            .map((signal) => {
                return `
          <article class="rounded-3xl border border-slate-200 bg-white p-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
            <div class="flex items-start gap-3">
              <div class="text-2xl">${this.escape(signal.icon || "✦")}</div>

              <div class="min-w-0">
                <div class="font-black text-slate-900 dark:text-white">
                  ${this.escape(signal.title)}
                </div>

                <p class="mt-1 text-xs leading-5 text-slate-500 dark:text-slate-400">
                  ${this.escape(signal.description)}
                </p>

                <div class="mt-3 h-1.5 overflow-hidden rounded-full bg-slate-100 dark:bg-slate-800">
                  <div
                    class="h-full rounded-full bg-gradient-to-r from-orange-400 to-violet-500"
                    style="width:${Math.min(Number(signal.score || 0), 100)}%"
                  ></div>
                </div>
              </div>
            </div>
          </article>
        `
            })
            .join("")
    }

    renderRecommendations(recommendations) {
        if (!recommendations.length) {
            this.recommendationsTarget.innerHTML = this.emptyState(
                "No recommendations are available for this entity yet."
            )

            return
        }

        this.recommendationsTarget.innerHTML = recommendations
            .map((recommendation) => {
                const type = recommendation.type || "entity"
                const icon = this.iconFor(type)
                const score = Math.round(
                    Number(recommendation.score || 0)
                )

                const reasons = (recommendation.reasons || [])
                    .slice(0, 2)
                    .map((reason) => {
                        return `
              <span class="rounded-full bg-slate-100 px-2.5 py-1 text-[10px] font-bold text-slate-500 dark:bg-slate-800 dark:text-slate-400">
                ${this.escape(reason)}
              </span>
            `
                    })
                    .join("")

                return `
          <article
            class="group rounded-[28px] border border-slate-200 bg-white p-5 shadow-sm transition hover:-translate-y-1 hover:border-violet-300 hover:shadow-xl dark:border-slate-800 dark:bg-slate-900"
          >
            <div class="flex items-start justify-between gap-4">
              <div class="flex min-w-0 items-center gap-3">
                <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-violet-100 text-xl dark:bg-violet-950/50">
                  ${icon}
                </div>

                <div class="min-w-0">
                  <div class="text-[10px] font-black uppercase tracking-widest text-violet-500">
                    ${this.escape(type)}
                  </div>

                  <div class="truncate font-black text-slate-900 dark:text-white">
                    ${this.escape(recommendation.name)}
                  </div>
                </div>
              </div>

              <div class="shrink-0 text-right">
                <div class="text-lg font-black text-violet-600">
                  ${score}
                </div>

                <div class="text-[9px] font-bold uppercase tracking-widest text-slate-400">
                  score
                </div>
              </div>
            </div>

            <div class="mt-4 flex flex-wrap gap-2">
              ${reasons}
            </div>

            <button
              type="button"
              class="mt-5 w-full rounded-2xl bg-slate-950 px-4 py-3 text-xs font-black text-white transition hover:bg-violet-600 dark:bg-white dark:text-slate-950 dark:hover:bg-violet-400"
              data-action="ecosystem-discovery#discoverRecommendation"
              data-id="${this.escapeAttribute(recommendation.id)}"
              data-type="${this.escapeAttribute(recommendation.type)}"
              data-name="${this.escapeAttribute(recommendation.name)}"
            >
              Discover this entity →
            </button>
          </article>
        `
            })
            .join("")
    }

    renderMissions(missions) {
        if (!missions.length) {
            this.missionsTarget.innerHTML = this.emptyState(
                "No missions generated yet."
            )

            return
        }

        this.missionsTarget.innerHTML = missions
            .map((mission) => {
                return `
          <article class="rounded-3xl border border-orange-200 bg-white/80 p-5 dark:border-orange-900/40 dark:bg-slate-900/70">
            <div class="flex items-start gap-3">
              <div class="text-2xl">${this.escape(mission.icon || "🧭")}</div>

              <div class="min-w-0 flex-1">
                <div class="flex flex-wrap items-center gap-2">
                  <h4 class="font-black text-slate-900 dark:text-white">
                    ${this.escape(mission.title)}
                  </h4>

                  <span class="rounded-full bg-orange-100 px-2 py-1 text-[9px] font-black uppercase tracking-widest text-orange-600 dark:bg-orange-950/50">
                    +${Number(mission.reward || 0)} XP
                  </span>
                </div>

                <p class="mt-1 text-xs leading-5 text-slate-500 dark:text-slate-400">
                  ${this.escape(mission.description)}
                </p>

                ${
                    mission.target
                        ? `
                      <div class="mt-3 rounded-2xl bg-orange-50 px-3 py-2 text-xs font-bold text-orange-700 dark:bg-orange-950/30 dark:text-orange-300">
                        Target: ${this.escape(mission.target)}
                      </div>
                    `
                        : ""
                }
              </div>
            </div>
          </article>
        `
            })
            .join("")
    }

    discoverRecommendation(event) {
        const button = event.currentTarget

        this.selectEntity({
            id: button.dataset.id,
            type: button.dataset.type,
            name: button.dataset.name
        })

        window.scrollTo({
            top: this.element.offsetTop - 40,
            behavior: "smooth"
        })
    }

    showLoading() {
        this.recommendationsTarget.classList.add("opacity-60")
    }

    clearError() {
        this.errorTarget.classList.add("hidden")
        this.errorTarget.textContent = ""
    }

    showError(message) {
        this.errorTarget.textContent = message
        this.errorTarget.classList.remove("hidden")
        this.recommendationsTarget.classList.remove("opacity-60")
    }

    emptyState(message) {
        return `
      <div class="rounded-3xl border border-dashed border-slate-300 p-6 text-sm text-slate-400 dark:border-slate-700">
        ${this.escape(message)}
      </div>
    `
    }

    iconFor(type) {
        return {
            problem: "🎯",
            method: "🧩",
            algorithm: "⚙️",
            technology: "🟢",
            entity: "🧬",
            version: "📦"
        }[type] || "🔗"
    }

    escape(value) {
        return String(value ?? "")
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;")
    }

    escapeAttribute(value) {
        return this.escape(value)
    }
}