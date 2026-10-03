import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "panel",
        "overall",
        "attention",
        "density",
        "balance",
        "movement",
        "risk",
        "evolution",
        "insights",
        "insightTemplate"
    ]

    static values = {
        payloadSelector: {
            type: String,
            default: "[data-entity-diff-payload]"
        }
    }

    connect() {
        this.analyze()

        this.refreshHandler = () => this.analyze()
        window.addEventListener("entity-diff:updated", this.refreshHandler)
    }

    disconnect() {
        window.removeEventListener("entity-diff:updated", this.refreshHandler)
    }

    analyze() {
        const payload = this.readPayload()

        if (!payload) {
            this.renderEmpty()
            return
        }

        const analysis = this.buildAnalysis(payload)

        this.renderAnalysis(analysis)
    }

    readPayload() {
        const node = this.element.querySelector(this.payloadSelectorValue)

        if (!node) return null

        try {
            return JSON.parse(node.textContent || "{}")
        } catch (error) {
            console.error("Comparison intelligence could not parse payload", error)
            return null
        }
    }

    buildAnalysis(payload) {
        const changes = this.extractChanges(payload)

        const changed = changes.filter(change => change.type === "changed")
        const moved = changes.filter(change => change.type === "moved")
        const added = changes.filter(change => change.type === "added")
        const removed = changes.filter(change => change.type === "removed")
        const warnings = changes.filter(change => change.type === "warning")

        const total = changes.length

        const pathCounts = this.calculatePathCounts(changes)

        const density = this.calculateDensity(changes)
        const balance = this.calculateBalance(added.length, removed.length)
        const movement = this.calculateMovement(moved.length, total)
        const risk = this.calculateRisk(warnings, removed, changed)
        const evolution = this.calculateEvolution({
            total,
            density,
            balance,
            movement,
            risk
        })

        const attention = this.calculateAttention({
            density,
            movement,
            risk,
            pathCounts,
            warnings,
            removed
        })

        const insights = this.buildInsights({
            changes,
            pathCounts,
            density,
            balance,
            movement,
            risk,
            evolution,
            attention
        })

        return {
            total,
            changed: changed.length,
            moved: moved.length,
            added: added.length,
            removed: removed.length,
            warnings: warnings.length,
            density,
            balance,
            movement,
            risk,
            evolution,
            attention,
            pathCounts,
            insights
        }
    }

    extractChanges(payload) {
        const candidates = []

        const buckets = [
            ["changed", payload.changed],
            ["changed", payload.changes],
            ["moved", payload.moved],
            ["added", payload.additions],
            ["removed", payload.removals],
            ["warning", payload.warnings]
        ]

        buckets.forEach(([type, collection]) => {
            if (!Array.isArray(collection)) return

            collection.forEach(item => {
                candidates.push({
                    ...item,
                    type: this.normalizeType(item.type || type)
                })
            })
        })

        if (candidates.length > 0) {
            return candidates
        }

        return this.extractGenericChanges(payload)
    }

    extractGenericChanges(payload) {
        const output = []

        const walk = value => {
            if (!value || typeof value !== "object") return

            if (Array.isArray(value)) {
                value.forEach(walk)
                return
            }

            if (value.type || value.change_type || value.kind) {
                const type = this.normalizeType(
                    value.type ||
                    value.change_type ||
                    value.kind
                )

                if (
                    [
                        "changed",
                        "moved",
                        "added",
                        "removed",
                        "warning"
                    ].includes(type)
                ) {
                    output.push({
                        ...value,
                        type
                    })
                }
            }

            Object.values(value).forEach(walk)
        }

        walk(payload)

        return output
    }

    normalizeType(type) {
        const value = String(type || "").toLowerCase()

        if (
            value.includes("move") ||
            value.includes("rename")
        ) {
            return "moved"
        }

        if (
            value.includes("add") ||
            value.includes("new") ||
            value.includes("create")
        ) {
            return "added"
        }

        if (
            value.includes("remove") ||
            value.includes("delete") ||
            value.includes("missing")
        ) {
            return "removed"
        }

        if (
            value.includes("warn") ||
            value.includes("identity") ||
            value.includes("conflict")
        ) {
            return "warning"
        }

        return "changed"
    }

    calculatePathCounts(changes) {
        const counts = {}

        changes.forEach(change => {
            const path =
                change.path ||
                change.key ||
                change.field ||
                change.name ||
                "Unknown path"

            const normalized = String(path)

            counts[normalized] = (counts[normalized] || 0) + 1
        })

        return Object.entries(counts)
            .map(([path, count]) => ({ path, count }))
            .sort((a, b) => b.count - a.count)
    }

    calculateDensity(changes) {
        if (changes.length === 0) return 0

        const uniquePaths = new Set(
            changes.map(change =>
                String(
                    change.path ||
                    change.key ||
                    change.field ||
                    change.name ||
                    "unknown"
                )
            )
        ).size

        const concentration = changes.length / Math.max(uniquePaths, 1)

        return Math.min(
            100,
            Math.round(concentration * 25)
        )
    }

    calculateBalance(added, removed) {
        const total = added + removed

        if (total === 0) return 50

        return Math.round(
            (added / total) * 100
        )
    }

    calculateMovement(moved, total) {
        if (total === 0) return 0

        return Math.round(
            (moved / total) * 100
        )
    }

    calculateRisk(warnings, removed, changed) {
        const score =
            warnings * 20 +
            removed * 8 +
            changed * 2

        return Math.min(
            100,
            score
        )
    }

    calculateEvolution({
                           total,
                           density,
                           balance,
                           movement,
                           risk
                       }) {
        if (total === 0) return 0

        const structural =
            Math.min(100, total * 5)

        const stability =
            100 - risk

        const balanceQuality =
            100 - Math.abs(50 - balance)

        return Math.round(
            (
                structural * 0.30 +
                density * 0.20 +
                movement * 0.15 +
                stability * 0.20 +
                balanceQuality * 0.15
            )
        )
    }

    calculateAttention({
                           density,
                           movement,
                           risk,
                           pathCounts,
                           warnings,
                           removed
                       }) {
        let score =
            density * 0.25 +
            movement * 0.15 +
            risk * 0.40 +
            Math.min(pathCounts.length * 3, 30) * 0.10 +
            Math.min(removed * 5, 100) * 0.10

        if (warnings.length > 0) {
            score += 15
        }

        return Math.min(
            100,
            Math.round(score)
        )
    }

    buildInsights({
                      changes,
                      pathCounts,
                      density,
                      balance,
                      movement,
                      risk,
                      evolution,
                      attention
                  }) {
        const insights = []

        if (risk >= 60) {
            insights.push({
                type: "risk",
                icon: "⚠️",
                title: "High attention area",
                description:
                    "Identity warnings, removals or structural changes deserve review before this comparison is considered complete.",
                priority: 100
            })
        }

        if (movement >= 30) {
            insights.push({
                type: "movement",
                icon: "↗",
                title: "Strong structural movement",
                description:
                    "A significant portion of the comparison involves moved or renamed material.",
                priority: 80
            })
        }

        if (density >= 60) {
            insights.push({
                type: "density",
                icon: "◈",
                title: "Change concentration detected",
                description:
                    "Changes are concentrated across a relatively small set of paths.",
                priority: 70
            })
        }

        if (balance >= 70) {
            insights.push({
                type: "growth",
                icon: "＋",
                title: "Addition-heavy evolution",
                description:
                    "The newer version introduces substantially more material than it removes.",
                priority: 55
            })
        }

        if (balance <= 30) {
            insights.push({
                type: "reduction",
                icon: "−",
                title: "Removal-heavy evolution",
                description:
                    "The newer version removes substantially more material than it introduces.",
                priority: 65
            })
        }

        if (pathCounts.length > 0) {
            const top = pathCounts[0]

            if (top.count >= 3) {
                insights.push({
                    type: "hotspot",
                    icon: "🔥",
                    title: "Structural hotspot",
                    description:
                        `"${top.path}" appears in ${top.count} detected changes and may deserve focused review.`,
                    priority: 75
                })
            }
        }

        if (attention >= 75) {
            insights.push({
                type: "attention",
                icon: "🎯",
                title: "Review priority elevated",
                description:
                    "The comparison contains several signals that can help prioritize human review.",
                priority: 90
            })
        }

        if (
            evolution >= 70 &&
            changes.length > 0
        ) {
            insights.push({
                type: "evolution",
                icon: "✨",
                title: "Meaningful evolution detected",
                description:
                    "The comparison contains enough structural activity to represent a meaningful version transition.",
                priority: 50
            })
        }

        return insights
            .sort((a, b) => b.priority - a.priority)
            .slice(0, 6)
    }

    renderAnalysis(analysis) {
        this.setValue(this.overallTarget, analysis.evolution)
        this.setValue(this.attentionTarget, analysis.attention)
        this.setValue(this.densityTarget, analysis.density)
        this.setValue(this.balanceTarget, analysis.balance)
        this.setValue(this.movementTarget, analysis.movement)
        this.setValue(this.riskTarget, analysis.risk)

        this.renderInsights(analysis.insights)

        this.dispatch(
            "analyzed",
            {
                detail: analysis
            }
        )
    }

    renderInsights(insights) {
        if (!this.hasInsightsTarget) return

        this.insightsTarget.innerHTML = ""

        if (insights.length === 0) {
            this.insightsTarget.innerHTML = `
        <div class="rounded-2xl border border-slate-100 bg-slate-50 p-5 text-sm text-slate-400">
          No significant intelligence signals detected yet.
        </div>
      `

            return
        }

        insights.forEach(insight => {
            const element = document.createElement("article")

            element.className =
                "group rounded-2xl border border-slate-100 bg-white p-4 shadow-sm transition-all duration-300 hover:-translate-y-0.5 hover:border-orange-200 hover:shadow-md"

            element.innerHTML = `
        <div class="flex items-start gap-3">
          <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-orange-50 text-base">
            ${insight.icon}
          </div>

          <div class="min-w-0">
            <div class="text-sm font-black text-slate-700">
              ${this.escapeHtml(insight.title)}
            </div>

            <p class="mt-1 text-xs leading-5 text-slate-400">
              ${this.escapeHtml(insight.description)}
            </p>
          </div>
        </div>
      `

            this.insightsTarget.appendChild(element)
        })
    }

    setValue(element, value) {
        element.textContent = `${value}%`

        element.style.setProperty(
            "--intelligence-progress",
            `${value}%`
        )
    }

    renderEmpty() {
        const targets = [
            this.overallTarget,
            this.attentionTarget,
            this.densityTarget,
            this.balanceTarget,
            this.movementTarget,
            this.riskTarget
        ]

        targets.forEach(target => {
            if (target) target.textContent = "—"
        })

        if (this.hasInsightsTarget) {
            this.insightsTarget.innerHTML = `
        <div class="rounded-2xl border border-slate-100 bg-slate-50 p-5 text-sm text-slate-400">
          Comparison intelligence will appear when comparison data is available.
        </div>
      `
        }
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