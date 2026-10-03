import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "score",
        "scoreLabel",
        "density",
        "densityBar",
        "evolution",
        "evolutionBar",
        "attention",
        "attentionList",
        "insightList",
        "changeTotal",
        "reviewedTotal",
        "remainingTotal",
        "focusButton"
    ]

    static values = {
        refreshInterval: {
            type: Number,
            default: 1200
        }
    }

    connect() {
        this.refreshTimer = null
        this.observer = null

        this.startWatching()
        this.refresh()

        this.handleKeydown = this.handleKeydown.bind(this)
        document.addEventListener("keydown", this.handleKeydown)
    }

    disconnect() {
        if (this.refreshTimer) {
            clearTimeout(this.refreshTimer)
        }

        if (this.observer) {
            this.observer.disconnect()
        }

        document.removeEventListener("keydown", this.handleKeydown)
    }

    startWatching() {
        this.observer = new MutationObserver(() => {
            this.scheduleRefresh()
        })

        this.observer.observe(document.body, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: [
                "class",
                "aria-pressed",
                "data-change-type"
            ]
        })
    }

    scheduleRefresh() {
        if (this.refreshTimer) {
            clearTimeout(this.refreshTimer)
        }

        this.refreshTimer = setTimeout(() => {
            this.refresh()
        }, this.refreshIntervalValue)
    }

    refresh() {
        const changes = this.collectChanges()

        const metrics = this.calculateMetrics(changes)

        this.renderMetrics(metrics)
        this.renderInsights(metrics)
        this.renderAttention(metrics)
    }

    collectChanges() {
        const candidates = Array.from(
            document.querySelectorAll(
                [
                    "[data-diff-item]",
                    "[data-change]",
                    "[data-entity-diff-change]",
                    "[data-diff-card]",
                    "[data-comparison-change]"
                ].join(",")
            )
        )

        const reviewedButtons = Array.from(
            document.querySelectorAll(
                "[data-comparison-review-button]"
            )
        )

        const candidateCards = candidates.length
            ? candidates
            : reviewedButtons
                .map((button) => this.findCardForButton(button))
                .filter(Boolean)

        const uniqueCards = Array.from(
            new Set(candidateCards)
        )

        return uniqueCards.map((card, index) => {
            const button = card.querySelector(
                "[data-comparison-review-button]"
            )

            const type = this.detectChangeType(card)

            const path =
                card.dataset.path ||
                card.dataset.changePath ||
                card.dataset.entityPath ||
                card.getAttribute("data-field") ||
                this.extractPathFromText(card) ||
                `change-${index + 1}`

            const reviewed =
                button?.getAttribute("aria-pressed") === "true" ||
                card.dataset.reviewed === "true" ||
                card.classList.contains("is-reviewed")

            const warning = this.detectWarning(card)

            const movement = this.detectMovement(card)

            const weight = this.weightFor(type, warning, movement)

            return {
                element: card,
                type,
                path,
                reviewed,
                warning,
                movement,
                weight
            }
        })
    }

    findCardForButton(button) {
        return (
            button.closest("[data-diff-item]") ||
            button.closest("[data-change]") ||
            button.closest("[data-entity-diff-change]") ||
            button.closest("[data-diff-card]") ||
            button.closest("[data-comparison-change]") ||
            button.parentElement
        )
    }

    detectChangeType(card) {
        const explicit =
            card.dataset.changeType ||
            card.dataset.type ||
            card.getAttribute("data-diff-type")

        if (explicit) {
            return this.normalizeType(explicit)
        }

        const text = card.innerText.toLowerCase()

        if (
            text.includes("removed") ||
            text.includes("removal") ||
            text.includes("deleted")
        ) {
            return "removed"
        }

        if (
            text.includes("added") ||
            text.includes("addition") ||
            text.includes("new")
        ) {
            return "added"
        }

        if (
            text.includes("moved") ||
            text.includes("movement") ||
            text.includes("relocated")
        ) {
            return "moved"
        }

        return "changed"
    }

    normalizeType(type) {
        const normalized = String(type)
            .trim()
            .toLowerCase()
            .replace(/[_\s]+/g, "-")

        if (normalized.includes("remove")) return "removed"
        if (normalized.includes("delete")) return "removed"
        if (normalized.includes("add")) return "added"
        if (normalized.includes("move")) return "moved"

        return "changed"
    }

    detectWarning(card) {
        if (
            card.dataset.warning === "true" ||
            card.dataset.risk === "high" ||
            card.dataset.identityWarning === "true"
        ) {
            return true
        }

        const text = card.innerText.toLowerCase()

        return [
            "identity warning",
            "identity risk",
            "high risk",
            "warning",
            "conflict",
            "uncertain identity",
            "possible mismatch"
        ].some((term) => text.includes(term))
    }

    detectMovement(card) {
        if (
            card.dataset.moved === "true" ||
            card.dataset.movement === "true"
        ) {
            return true
        }

        const text = card.innerText.toLowerCase()

        return (
            text.includes("moved from") ||
            text.includes("moved to") ||
            text.includes("relocated") ||
            text.includes("movement")
        )
    }

    extractPathFromText(card) {
        const pathElement =
            card.querySelector(
                "[data-path-label]"
            ) ||
            card.querySelector(
                "code"
            ) ||
            card.querySelector(
                "[class*='font-mono']"
            )

        if (pathElement?.textContent?.trim()) {
            return pathElement.textContent.trim()
        }

        return null
    }

    weightFor(type, warning, movement) {
        let weight = 1

        if (type === "removed") weight += 1
        if (type === "moved") weight += 1
        if (type === "changed") weight += 0.5

        if (warning) weight += 3
        if (movement) weight += 1

        return weight
    }

    calculateMetrics(changes) {
        const total = changes.length

        const reviewed = changes.filter(
            (change) => change.reviewed
        ).length

        const remaining = Math.max(
            total - reviewed,
            0
        )

        const weightedTotal = changes.reduce(
            (sum, change) => sum + change.weight,
            0
        )

        const weightedReviewed = changes
            .filter((change) => change.reviewed)
            .reduce(
                (sum, change) => sum + change.weight,
                0
            )

        const weightedRemaining =
            Math.max(
                weightedTotal - weightedReviewed,
                0
            )

        const density = this.calculateDensity(
            changes
        )

        const evolution = this.calculateEvolution(
            changes
        )

        const attention = this.calculateAttention(
            changes,
            weightedRemaining
        )

        const byType = {
            changed: changes.filter(
                (change) => change.type === "changed"
            ).length,

            added: changes.filter(
                (change) => change.type === "added"
            ).length,

            removed: changes.filter(
                (change) => change.type === "removed"
            ).length,

            moved: changes.filter(
                (change) => change.type === "moved"
            ).length
        }

        const warnings = changes.filter(
            (change) => change.warning
        ).length

        const movements = changes.filter(
            (change) => change.movement
        ).length

        const paths = this.aggregatePaths(changes)

        const reviewPercent =
            total > 0
                ? Math.round((reviewed / total) * 100)
                : 0

        return {
            total,
            reviewed,
            remaining,
            reviewPercent,
            weightedTotal,
            weightedReviewed,
            weightedRemaining,
            density,
            evolution,
            attention,
            warnings,
            movements,
            byType,
            paths,
            changes
        }
    }

    calculateDensity(changes) {
        if (!changes.length) return 0

        const uniquePaths = new Set(
            changes.map((change) => change.path)
        ).size

        const pathFactor =
            uniquePaths / Math.max(changes.length, 1)

        const raw =
            changes.length * (1.25 - pathFactor)

        return Math.min(
            100,
            Math.max(
                0,
                Math.round(raw * 12)
            )
        )
    }

    calculateEvolution(changes) {
        if (!changes.length) return 0

        const added = changes.filter(
            (change) => change.type === "added"
        ).length

        const removed = changes.filter(
            (change) => change.type === "removed"
        ).length

        const moved = changes.filter(
            (change) => change.type === "moved"
        ).length

        const changed = changes.filter(
            (change) => change.type === "changed"
        ).length

        const structural =
            added +
            removed +
            moved

        const structuralRatio =
            structural / changes.length

        const variety =
            [
                added > 0,
                removed > 0,
                moved > 0,
                changed > 0
            ].filter(Boolean).length / 4

        return Math.min(
            100,
            Math.round(
                (
                    structuralRatio * 65 +
                    variety * 35
                )
            )
        )
    }

    calculateAttention(
        changes,
        weightedRemaining
    ) {
        if (!changes.length) return 0

        const warnings =
            changes.filter(
                (change) =>
                    change.warning &&
                    !change.reviewed
            ).length

        const unresolved =
            changes.filter(
                (change) =>
                    !change.reviewed
            ).length

        const maxWeight =
            changes.reduce(
                (max, change) =>
                    Math.max(max, change.weight),
                0
            )

        const weightedFactor =
            weightedRemaining /
            Math.max(
                changes.length * Math.max(maxWeight, 1),
                1
            )

        const warningFactor =
            warnings /
            Math.max(changes.length, 1)

        const unresolvedFactor =
            unresolved /
            Math.max(changes.length, 1)

        return Math.min(
            100,
            Math.round(
                weightedFactor * 45 +
                warningFactor * 35 +
                unresolvedFactor * 20
            )
        )
    }

    aggregatePaths(changes) {
        const map = new Map()

        changes.forEach((change) => {
            const current =
                map.get(change.path) || {
                    path: change.path,
                    count: 0,
                    weight: 0,
                    warnings: 0,
                    reviewed: 0
                }

            current.count += 1
            current.weight += change.weight

            if (change.warning) {
                current.warnings += 1
            }

            if (change.reviewed) {
                current.reviewed += 1
            }

            map.set(
                change.path,
                current
            )
        })

        return Array.from(map.values())
            .sort(
                (a, b) =>
                    b.weight - a.weight
            )
            .slice(0, 6)
    }

    renderMetrics(metrics) {
        this.setText(
            this.scoreTarget,
            metrics.attention
        )

        this.setText(
            this.densityTarget,
            `${metrics.density}%`
        )

        this.setText(
            this.evolutionTarget,
            `${metrics.evolution}%`
        )

        this.setText(
            this.changeTotalTarget,
            metrics.total
        )

        this.setText(
            this.reviewedTotalTarget,
            metrics.reviewed
        )

        this.setText(
            this.remainingTotalTarget,
            metrics.remaining
        )

        if (this.hasDensityBarTarget) {
            this.densityBarTarget.style.width =
                `${metrics.density}%`
        }

        if (this.hasEvolutionBarTarget) {
            this.evolutionBarTarget.style.width =
                `${metrics.evolution}%`
        }

        if (this.hasScoreLabelTarget) {
            this.scoreLabelTarget.textContent =
                this.attentionLabel(
                    metrics.attention
                )
        }
    }

    renderAttention(metrics) {
        if (!this.hasAttentionListTarget) {
            return
        }

        if (!metrics.paths.length) {
            this.attentionListTarget.innerHTML = `
        <div class="rounded-2xl border border-slate-200 bg-white p-5 text-center">
          <div class="text-sm font-black text-slate-700">
            No structural hotspots yet
          </div>
          <div class="mt-1 text-xs text-slate-400">
            Intelligence will appear when comparison changes are available.
          </div>
        </div>
      `

            return
        }

        this.attentionListTarget.innerHTML =
            metrics.paths
                .map((item, index) => {
                    const percent =
                        Math.min(
                            100,
                            Math.round(
                                (item.weight /
                                    Math.max(
                                        metrics.weightedTotal,
                                        1
                                    )) *
                                100
                            )
                        )

                    const warningBadge =
                        item.warnings > 0
                            ? `
                <span class="rounded-full border border-amber-200 bg-amber-50 px-2 py-1 text-[9px] font-black uppercase tracking-wider text-amber-700">
                  ${item.warnings} warning${item.warnings > 1 ? "s" : ""}
                </span>
              `
                            : ""

                    return `
            <button
              type="button"
              data-intelligence-path="${this.escapeAttribute(item.path)}"
              data-action="click->comparison-intelligence#focusPath"
              class="group w-full rounded-2xl border border-slate-200 bg-white p-4 text-left shadow-sm transition hover:-translate-y-0.5 hover:border-orange-200 hover:shadow-md">

              <div class="flex items-start gap-3">

                <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-slate-100 text-xs font-black text-slate-500">
                  ${index + 1}
                </div>

                <div class="min-w-0 flex-1">

                  <div class="flex flex-wrap items-center gap-2">
                    <span class="truncate font-mono text-xs font-bold text-slate-700">
                      ${this.escapeHtml(item.path)}
                    </span>

                    ${warningBadge}
                  </div>

                  <div class="mt-2 h-1.5 overflow-hidden rounded-full bg-slate-100">
                    <div
                      class="h-full rounded-full bg-gradient-to-r from-orange-400 via-amber-400 to-violet-400 transition-all duration-700"
                      style="width:${percent}%">
                    </div>
                  </div>

                  <div class="mt-2 flex items-center justify-between text-[10px] font-bold text-slate-400">
                    <span>
                      ${item.count} change${item.count !== 1 ? "s" : ""}
                    </span>

                    <span class="text-orange-500">
                      ${percent}% attention
                    </span>
                  </div>

                </div>

              </div>
            </button>
          `
                })
                .join("")
    }

    renderInsights(metrics) {
        if (!this.hasInsightListTarget) {
            return
        }

        const insights = []

        if (metrics.warnings > 0) {
            insights.push({
                icon: "⚠️",
                color: "amber",
                title: "Identity review required",
                body: `${metrics.warnings} comparison change${metrics.warnings > 1 ? "s" : ""} contain${metrics.warnings === 1 ? "s" : ""} a warning signal.`
            })
        }

        if (metrics.byType.removed > metrics.byType.added) {
            insights.push({
                icon: "↘",
                color: "rose",
                title: "Removal pressure",
                body: "The comparison contains more removals than additions, indicating contraction in the compared version."
            })
        }

        if (metrics.byType.added > metrics.byType.removed) {
            insights.push({
                icon: "↗",
                color: "emerald",
                title: "Expansion pressure",
                body: "The comparison contains more additions than removals, indicating structural expansion."
            })
        }

        if (metrics.movements > 0) {
            insights.push({
                icon: "⇄",
                color: "violet",
                title: "Structural movement",
                body: `${metrics.movements} movement signal${metrics.movements > 1 ? "s" : ""} suggest${metrics.movements === 1 ? "s" : ""} that content changed location as well as value.`
            })
        }

        if (metrics.density >= 60) {
            insights.push({
                icon: "◉",
                color: "orange",
                title: "High change density",
                body: "Changes are concentrated across a relatively small set of paths. Review the hotspot list first."
            })
        }

        if (
            metrics.remaining > 0 &&
            metrics.reviewPercent >= 50
        ) {
            insights.push({
                icon: "🔥",
                color: "orange",
                title: "Review momentum",
                body: `${metrics.reviewPercent}% of detected changes have already been reviewed.`
            })
        }

        if (
            metrics.remaining === 0 &&
            metrics.total > 0
        ) {
            insights.push({
                icon: "✓",
                color: "emerald",
                title: "Comparison reviewed",
                body: "Every detected change has been marked reviewed."
            })
        }

        if (!insights.length) {
            insights.push({
                icon: "✦",
                color: "sky",
                title: "Awaiting comparison signals",
                body: "Once the comparison engine exposes changes, intelligence will prioritize the most important areas."
            })
        }

        this.insightListTarget.innerHTML =
            insights
                .slice(0, 5)
                .map(
                    (insight) => this.insightHtml(
                        insight
                    )
                )
                .join("")
    }

    insightHtml(insight) {
        const colors = {
            amber: [
                "bg-amber-50",
                "border-amber-200",
                "text-amber-700"
            ],
            rose: [
                "bg-rose-50",
                "border-rose-200",
                "text-rose-700"
            ],
            emerald: [
                "bg-emerald-50",
                "border-emerald-200",
                "text-emerald-700"
            ],
            violet: [
                "bg-violet-50",
                "border-violet-200",
                "text-violet-700"
            ],
            orange: [
                "bg-orange-50",
                "border-orange-200",
                "text-orange-700"
            ],
            sky: [
                "bg-sky-50",
                "border-sky-200",
                "text-sky-700"
            ]
        }

        const [
            background,
            border,
            text
        ] =
        colors[insight.color] ||
        colors.sky

        return `
      <div class="rounded-2xl border ${border} ${background} p-4">

        <div class="flex items-start gap-3">

          <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-white/80 text-base shadow-sm">
            ${insight.icon}
          </div>

          <div>
            <div class="text-xs font-black ${text}">
              ${this.escapeHtml(insight.title)}
            </div>

            <p class="mt-1 text-[11px] leading-5 text-slate-500">
              ${this.escapeHtml(insight.body)}
            </p>
          </div>

        </div>

      </div>
    `
    }

    focusPath(event) {
        const path =
            event.currentTarget.dataset.intelligencePath

        if (!path) return

        const changes =
            this.collectChanges()

        const match =
            changes.find(
                (change) =>
                    change.path === path
            )

        if (!match?.element) {
            return
        }

        match.element.scrollIntoView({
            behavior: "smooth",
            block: "center"
        })

        match.element.classList.add(
            "ring-4",
            "ring-orange-200",
            "border-orange-300"
        )

        setTimeout(() => {
            match.element.classList.remove(
                "ring-4",
                "ring-orange-200",
                "border-orange-300"
            )
        }, 1800)
    }

    focusHighestPriority() {
        const changes =
            this.collectChanges()

        const remaining =
            changes
                .filter(
                    (change) =>
                        !change.reviewed
                )
                .sort(
                    (a, b) =>
                        b.weight - a.weight
                )

        const target =
            remaining[0] ||
            changes[0]

        if (!target?.element) {
            return
        }

        target.element.scrollIntoView({
            behavior: "smooth",
            block: "center"
        })

        target.element.classList.add(
            "ring-4",
            "ring-orange-300"
        )

        setTimeout(() => {
            target.element.classList.remove(
                "ring-4",
                "ring-orange-300"
            )
        }, 1800)
    }

    handleKeydown(event) {
        if (
            event.target.matches(
                "input, textarea, select, [contenteditable='true']"
            )
        ) {
            return
        }

        if (
            event.key.toLowerCase() === "i" &&
            !event.metaKey &&
            !event.ctrlKey
        ) {
            this.focusHighestPriority()
        }
    }

    attentionLabel(score) {
        if (score >= 75) {
            return "High attention"
        }

        if (score >= 45) {
            return "Focused review"
        }

        if (score > 0) {
            return "Low attention"
        }

        return "No active signals"
    }

    setText(element, value) {
        if (element) {
            element.textContent = value
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

    escapeAttribute(value) {
        return this.escapeHtml(value)
    }
}