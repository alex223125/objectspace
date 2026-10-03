import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "grid",
        "attention",
        "impact",
        "structure",
        "review",
        "summary",
        "timeline"
    ]

    connect() {
        this.refresh()
    }

    refresh() {
        const rows = this.collectRows()
        const intelligence = this.analyze(rows)

        this.renderSummary(intelligence)
        this.renderInsights(intelligence)
        this.renderTimeline(intelligence)
    }

    collectRows() {
        return Array.from(
            this.element.querySelectorAll(
                "[data-comparison-row], [data-diff-row], [data-change-row]"
            )
        ).map((row, index) => {
            const type = (
                row.dataset.changeType ||
                row.dataset.diffType ||
                row.dataset.type ||
                "changed"
            ).toLowerCase()

            const path =
                row.dataset.path ||
                row.querySelector(
                    "[data-comparison-path], [data-diff-path]"
                )?.textContent?.trim() ||
                `change-${index + 1}`

            const text = row.innerText || ""

            return {
                type,
                path,
                text,
                reviewed:
                    row.dataset.reviewed === "true" ||
                    row.getAttribute("aria-pressed") === "true"
            }
        })
    }

    analyze(rows) {
        const total = rows.length

        const changed = rows.filter(
            row => row.type.includes("change")
        ).length

        const added = rows.filter(
            row => row.type.includes("add")
        ).length

        const removed = rows.filter(
            row => row.type.includes("remove")
        ).length

        const moved = rows.filter(
            row => row.type.includes("move")
        ).length

        const warnings = rows.filter(
            row =>
                row.type.includes("warning") ||
                /identity|warning|risk/i.test(row.text)
        ).length

        const reviewed = rows.filter(
            row => row.reviewed
        ).length

        const reviewCoverage =
            total === 0
                ? 0
                : Math.round((reviewed / total) * 100)

        const structuralChange =
            added + removed + moved

        const impact =
            Math.min(
                100,
                Math.round(
                    (
                        changed * 1 +
                        added * 1.2 +
                        removed * 1.4 +
                        moved * 1.6 +
                        warnings * 2
                    ) * 8
                )
            )

        const structure =
            total === 0
                ? 0
                : Math.min(
                    100,
                    Math.round(
                        (structuralChange / total) * 100
                    )
                )

        const attention =
            Math.min(
                100,
                Math.round(
                    warnings * 25 +
                    removed * 8 +
                    moved * 7 +
                    Math.max(0, 70 - reviewCoverage) * 0.3
                )
            )

        return {
            total,
            changed,
            added,
            removed,
            moved,
            warnings,
            reviewed,
            reviewCoverage,
            impact,
            structure,
            attention
        }
    }

    renderSummary(data) {
        this.setValue(
            this.hasAttentionTarget ? this.attentionTarget : null,
            data.attention
        )

        this.setValue(
            this.hasImpactTarget ? this.impactTarget : null,
            data.impact
        )

        this.setValue(
            this.hasStructureTarget ? this.structureTarget : null,
            data.structure
        )

        this.setValue(
            this.hasReviewTarget ? this.reviewTarget : null,
            data.reviewCoverage
        )

        if (this.hasSummaryTarget) {
            this.summaryTarget.textContent =
                this.summaryText(data)
        }
    }

    setValue(element, value) {
        if (!element) return

        element.textContent = value

        const progress =
            element.closest("[data-insight-progress]")

        if (progress) {
            const bar =
                progress.querySelector("[data-insight-bar]")

            if (bar) {
                bar.style.width = `${value}%`
            }
        }
    }

    summaryText(data) {
        if (data.total === 0) {
            return "No comparison changes are available for interpretation yet."
        }

        if (data.attention >= 70) {
            return "This comparison contains several signals that deserve focused review."
        }

        if (data.impact >= 70) {
            return "The newer version represents meaningful structural evolution."
        }

        if (data.reviewCoverage >= 80) {
            return "Most detected changes have already been reviewed."
        }

        return "The comparison contains actionable changes that can be reviewed progressively."
    }

    renderInsights(data) {
        if (!this.hasGridTarget) return

        const cards = [
            this.attentionInsight(data),
            this.impactInsight(data),
            this.structureInsight(data),
            this.reviewInsight(data)
        ]

        this.gridTarget.innerHTML = cards
            .map(card => this.cardTemplate(card))
            .join("")
    }

    attentionInsight(data) {
        if (data.warnings > 0) {
            return {
                icon: "⚠️",
                tone: "amber",
                label: "Attention signal",
                title: "Identity and risk signals detected",
                description:
                    `${data.warnings} potential warning signal${data.warnings === 1 ? "" : "s"} deserve closer inspection.`,
                action: "Review warnings"
            }
        }

        if (data.removed > 0) {
            return {
                icon: "🔎",
                tone: "rose",
                label: "Attention signal",
                title: "Removed content deserves review",
                description:
                    `${data.removed} removal${data.removed === 1 ? "" : "s"} may represent meaningful evolution or cleanup.`,
                action: "Inspect removals"
            }
        }

        return {
            icon: "🎯",
            tone: "sky",
            label: "Attention signal",
            title: "No major risk concentration detected",
            description:
                "The current comparison does not show a strong concentration of warning signals.",
            action: "Continue review"
        }
    }

    impactInsight(data) {
        if (data.impact >= 70) {
            return {
                icon: "🔥",
                tone: "orange",
                label: "Impact signal",
                title: "High-impact evolution",
                description:
                    "Multiple change categories combine to indicate substantial version evolution.",
                action: "Explore major changes"
            }
        }

        if (data.impact >= 35) {
            return {
                icon: "⚡",
                tone: "amber",
                label: "Impact signal",
                title: "Moderate evolution",
                description:
                    "The newer version introduces several meaningful changes.",
                action: "Review impact"
            }
        }

        return {
            icon: "🌱",
            tone: "emerald",
            label: "Impact signal",
            title: "Incremental evolution",
            description:
                "The comparison appears relatively focused rather than broadly structural.",
            action: "Explore changes"
        }
    }

    structureInsight(data) {
        if (data.moved > data.added && data.moved > data.removed) {
            return {
                icon: "↔",
                tone: "violet",
                label: "Structure signal",
                title: "Movement dominates the evolution",
                description:
                    "The strongest structural signal comes from content being repositioned or reorganized.",
                action: "Inspect movement"
            }
        }

        if (data.added > data.removed) {
            return {
                icon: "↗",
                tone: "emerald",
                label: "Structure signal",
                title: "The ecosystem is expanding",
                description:
                    "More content was added than removed in this comparison.",
                action: "Explore additions"
            }
        }

        if (data.removed > data.added) {
            return {
                icon: "↘",
                tone: "rose",
                label: "Structure signal",
                title: "The ecosystem is consolidating",
                description:
                    "More content was removed than added in this comparison.",
                action: "Explore removals"
            }
        }

        return {
            icon: "◇",
            tone: "violet",
            label: "Structure signal",
            title: "Balanced structural evolution",
            description:
                "Additions and removals remain relatively balanced.",
            action: "Inspect structure"
        }
    }

    reviewInsight(data) {
        if (data.reviewCoverage >= 90) {
            return {
                icon: "🏆",
                tone: "emerald",
                label: "Review signal",
                title: "Review almost complete",
                description:
                    "The comparison has reached a high level of review coverage.",
                action: "Complete review"
            }
        }

        if (data.reviewCoverage >= 50) {
            return {
                icon: "🚀",
                tone: "sky",
                label: "Review signal",
                title: "Review is progressing",
                description:
                    `${data.reviewCoverage}% of detected changes have been reviewed.`,
                action: "Continue reviewing"
            }
        }

        return {
            icon: "🎯",
            tone: "orange",
            label: "Review signal",
            title: "A substantial review remains",
            description:
                `${Math.max(0, 100 - data.reviewCoverage)}% of detected changes remain available for review.`,
            action: "Start focused review"
        }
    }

    cardTemplate(card) {
        const tones = {
            amber: {
                shell: "border-amber-100 bg-amber-50/50",
                icon: "bg-amber-100 text-amber-700",
                label: "text-amber-600"
            },

            rose: {
                shell: "border-rose-100 bg-rose-50/50",
                icon: "bg-rose-100 text-rose-700",
                label: "text-rose-600"
            },

            sky: {
                shell: "border-sky-100 bg-sky-50/50",
                icon: "bg-sky-100 text-sky-700",
                label: "text-sky-600"
            },

            orange: {
                shell: "border-orange-100 bg-orange-50/50",
                icon: "bg-orange-100 text-orange-700",
                label: "text-orange-600"
            },

            emerald: {
                shell: "border-emerald-100 bg-emerald-50/50",
                icon: "bg-emerald-100 text-emerald-700",
                label: "text-emerald-600"
            },

            violet: {
                shell: "border-violet-100 bg-violet-50/50",
                icon: "bg-violet-100 text-violet-700",
                label: "text-violet-600"
            }
        }

        const tone = tones[card.tone] || tones.sky

        return `
      <article
        class="
          group relative overflow-hidden rounded-[26px]
          border p-5 ${tone.shell}
          transition-all duration-300
          hover:-translate-y-1
          hover:shadow-lg
        "
      >

        <div
          class="
            absolute -right-8 -top-8
            h-24 w-24 rounded-full
            bg-white/50 blur-2xl
          "
        ></div>

        <div class="relative">

          <div class="flex items-start justify-between gap-3">

            <div
              class="
                flex h-11 w-11 shrink-0
                items-center justify-center
                rounded-2xl ${tone.icon}
                text-lg shadow-sm
              "
            >
              ${card.icon}
            </div>

            <span
              class="
                rounded-full
                bg-white/70
                px-2.5 py-1
                text-[9px]
                font-black
                uppercase
                tracking-widest
                ${tone.label}
              "
            >
              ${this.escape(card.label)}
            </span>

          </div>

          <h4
            class="
              mt-5
              text-sm
              font-black
              tracking-tight
              text-slate-800
            "
          >
            ${this.escape(card.title)}
          </h4>

          <p
            class="
              mt-2
              text-[11px]
              leading-5
              text-slate-500
            "
          >
            ${this.escape(card.description)}
          </p>

          <div
            class="
              mt-5
              flex items-center justify-between
              border-t border-white/70
              pt-3
            "
          >
            <span
              class="
                text-[10px]
                font-black
                text-slate-500
              "
            >
              ${this.escape(card.action)}
            </span>

            <span
              class="
                transition-transform
                duration-300
                group-hover:translate-x-1
              "
            >
              →
            </span>
          </div>

        </div>

      </article>
    `
    }

    renderTimeline(data) {
        if (!this.hasTimelineTarget) return

        const events = []

        if (data.added > 0) {
            events.push({
                icon: "+",
                tone: "emerald",
                title: "Expansion",
                text: `${data.added} addition${data.added === 1 ? "" : "s"} detected.`
            })
        }

        if (data.changed > 0) {
            events.push({
                icon: "~",
                tone: "orange",
                title: "Modification",
                text: `${data.changed} changed element${data.changed === 1 ? "" : "s"} detected.`
            })
        }

        if (data.moved > 0) {
            events.push({
                icon: "↔",
                tone: "violet",
                title: "Reorganization",
                text: `${data.moved} moved element${data.moved === 1 ? "" : "s"} detected.`
            })
        }

        if (data.removed > 0) {
            events.push({
                icon: "−",
                tone: "rose",
                title: "Consolidation",
                text: `${data.removed} removal${data.removed === 1 ? "" : "s"} detected.`
            })
        }

        if (data.warnings > 0) {
            events.push({
                icon: "!",
                tone: "amber",
                title: "Risk signal",
                text: `${data.warnings} warning signal${data.warnings === 1 ? "" : "s"} detected.`
            })
        }

        if (events.length === 0) {
            this.timelineTarget.innerHTML = `
        <div class="rounded-2xl border border-dashed border-slate-200 bg-slate-50 p-5 text-center text-xs text-slate-400">
          No evolution events detected yet.
        </div>
      `

            return
        }

        this.timelineTarget.innerHTML = events
            .map((event, index) => `
        <div class="relative flex gap-4">

          ${
                index < events.length - 1
                    ? `
                <div
                  class="
                    absolute left-[17px]
                    top-9 bottom-[-14px]
                    w-px bg-slate-200
                  "
                ></div>
              `
                    : ""
            }

          <div
            class="
              relative z-10
              flex h-9 w-9 shrink-0
              items-center justify-center
              rounded-xl
              bg-white
              border border-slate-200
              text-xs font-black
              shadow-sm
            "
          >
            ${event.icon}
          </div>

          <div class="pb-5">

            <div class="text-xs font-black text-slate-700">
              ${this.escape(event.title)}
            </div>

            <div class="mt-1 text-[11px] leading-5 text-slate-400">
              ${this.escape(event.text)}
            </div>

          </div>

        </div>
      `)
            .join("")
    }

    escape(value) {
        return String(value)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;")
    }
}