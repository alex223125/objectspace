import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "metrics",
        "relationships",
        "graph",
        "status"
    ]

    static values = {
        entityId: Number,
        url: String
    }

    connect() {
        this.refresh()
    }

    async refresh() {
        if (!this.hasUrlValue) {
            return
        }

        this.setStatus("SYNCING")

        try {
            const response = await fetch(this.urlValue, {
                headers: {
                    "Accept": "application/json",
                    "X-Requested-With": "XMLHttpRequest"
                },
                credentials: "same-origin"
            })

            if (!response.ok) {
                throw new Error(
                    `Relationship intelligence request failed: ${response.status}`
                )
            }

            const payload = await response.json()

            this.render(payload)

            this.setStatus("LIVE")
        } catch (error) {
            console.error(
                "Relationship intelligence:",
                error
            )

            this.setStatus("OFFLINE")
        }
    }

    render(payload) {
        this.renderMetrics(payload.metrics)
        this.renderRelationships(payload.relationships)
        this.renderGraph(payload)
    }

    renderMetrics(metrics) {
        if (!this.hasMetricsTarget) {
            return
        }

        const cards = [
            {
                label: "RELATIONSHIPS",
                value: metrics.total_relationships,
                icon: "◈",
                color: "violet"
            },
            {
                label: "CONFIRMED",
                value: metrics.confirmed_relationships,
                icon: "✓",
                color: "emerald"
            },
            {
                label: "SUGGESTED",
                value: metrics.suggested_relationships,
                icon: "✦",
                color: "amber"
            },
            {
                label: "AVG CONFIDENCE",
                value: `${metrics.average_confidence_percent}%`,
                icon: "◎",
                color: "sky"
            }
        ]

        this.metricsTarget.innerHTML =
            cards.map((card) => `
        <div class="rounded-2xl border border-gray-200 bg-white p-4 shadow-sm dark:border-gray-800 dark:bg-gray-900">
          <div class="flex items-center justify-between">
            <span class="text-[9px] font-black uppercase tracking-[0.18em] text-gray-400">
              ${this.escape(card.label)}
            </span>
            <span class="text-sm text-${card.color}-500">
              ${this.escape(card.icon)}
            </span>
          </div>

          <div class="mt-2 text-2xl font-black text-gray-800 dark:text-white">
            ${this.escape(card.value)}
          </div>
        </div>
      `).join("")
    }

    renderRelationships(relationships) {
        if (!this.hasRelationshipsTarget) {
            return
        }

        if (!relationships.length) {
            this.relationshipsTarget.innerHTML = `
        <div class="rounded-2xl border border-dashed border-gray-200 px-4 py-10 text-center dark:border-gray-800">
          <div class="text-2xl">◌</div>
          <div class="mt-2 text-xs font-black text-gray-700 dark:text-gray-200">
            No relationship signals yet
          </div>
          <p class="mx-auto mt-1 max-w-xs text-[10px] leading-relaxed text-gray-400">
            Run relationship discovery to identify possible connections.
          </p>
        </div>
      `

            return
        }

        this.relationshipsTarget.innerHTML =
            relationships.map((relationship) => {
                const confidence =
                    Number(relationship.confidence_percent || 0)

                const evidence =
                    Array.isArray(relationship.evidence)
                        ? relationship.evidence
                        : []

                return `
          <div class="group rounded-2xl border border-gray-100 bg-gray-50 p-3 transition hover:border-violet-200 hover:bg-violet-50/40 dark:border-gray-800 dark:bg-gray-950">

            <div class="flex items-start justify-between gap-3">

              <div class="min-w-0">
                <div class="truncate text-xs font-black text-gray-800 dark:text-gray-100">
                  ${this.escape(relationship.entity_name || "Unknown entity")}
                </div>

                <div class="mt-1 truncate font-mono text-[9px] text-gray-400">
                  ${this.escape(relationship.entity_slug || "")}
                </div>
              </div>

              <span class="shrink-0 rounded-full border border-violet-200 bg-violet-50 px-2 py-1 text-[8px] font-black uppercase tracking-wider text-violet-600 dark:border-violet-900 dark:bg-violet-950/30 dark:text-violet-400">
                ${this.escape(relationship.relationship_label || "")}
              </span>

            </div>

            <div class="mt-3">

              <div class="flex items-center justify-between text-[8px] font-black uppercase tracking-wider">
                <span class="text-gray-400">
                  Confidence
                </span>

                <span class="text-gray-500 dark:text-gray-400">
                  ${confidence}%
                </span>
              </div>

              <div class="mt-1 h-1.5 overflow-hidden rounded-full bg-gray-200 dark:bg-gray-800">
                <div
                  class="h-full rounded-full bg-gradient-to-r from-amber-400 via-sky-400 to-violet-500"
                  style="width: ${confidence}%">
                </div>
              </div>

            </div>

            ${
                    evidence.length
                        ? `
                  <div class="mt-3 flex flex-wrap gap-1">
                    ${evidence.map((item) => `
                      <span class="rounded-md bg-white px-1.5 py-1 text-[8px] font-bold text-gray-500 dark:bg-gray-900 dark:text-gray-400">
                        ${this.escape(
                            this.humanize(
                                item.signal || ""
                            )
                        )}
                      </span>
                    `).join("")}
                  </div>
                `
                        : ""
                }

          </div>
        `
            }).join("")
    }

    renderGraph(payload) {
        if (!this.hasGraphTarget) {
            return
        }

        const nodes =
            Array.isArray(payload.nodes)
                ? payload.nodes
                : []

        const edges =
            Array.isArray(payload.edges)
                ? payload.edges
                : []

        if (!nodes.length) {
            this.graphTarget.innerHTML = `
        <div class="flex min-h-[360px] items-center justify-center rounded-2xl border border-slate-800 bg-slate-950">
          <div class="text-center">
            <div class="text-3xl">◈</div>
            <div class="mt-2 text-xs font-black text-slate-300">
              Relationship graph empty
            </div>
            <div class="mt-1 text-[10px] text-slate-500">
              Discover relationships to populate the network.
            </div>
          </div>
        </div>
      `

            return
        }

        const center = nodes[0]
        const satellites = nodes.slice(1, 9)

        const positions = [
            ["8%", "15%"],
            ["38%", "5%"],
            ["72%", "10%"],
            ["82%", "38%"],
            ["72%", "72%"],
            ["38%", "80%"],
            ["8%", "70%"],
            ["3%", "40%"]
        ]

        this.graphTarget.innerHTML = `
      <div class="relative min-h-[360px] overflow-hidden rounded-2xl border border-slate-800 bg-slate-950">

        <div
          class="pointer-events-none absolute inset-0 opacity-30"
          style="
            background-image:
              linear-gradient(rgba(139,92,246,.10) 1px, transparent 1px),
              linear-gradient(90deg, rgba(139,92,246,.10) 1px, transparent 1px);
            background-size: 28px 28px;
          ">
        </div>

        <div class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2">

          <div class="flex h-24 w-24 items-center justify-center rounded-full border-2 border-violet-400/70 bg-violet-500/20 p-3 text-center shadow-[0_0_45px_rgba(139,92,246,.25)]">

            <span class="line-clamp-3 text-[9px] font-black uppercase tracking-wider text-white">
              ${this.escape(center.name)}
            </span>

          </div>

        </div>

        ${
            satellites.map((node, index) => `
            <div
              class="absolute -translate-x-1/2 -translate-y-1/2"
              style="left:${positions[index][0]};top:${positions[index][1]};">

              <div class="flex h-16 w-16 items-center justify-center rounded-full border border-sky-400/40 bg-sky-500/10 p-2 text-center shadow-lg">

                <span class="line-clamp-3 text-[7px] font-black uppercase tracking-wider text-sky-200">
                  ${this.escape(node.name)}
                </span>

              </div>

            </div>
          `).join("")
        }

        <div class="absolute bottom-3 left-3 right-3 flex items-center justify-between">

          <span class="rounded-full border border-violet-400/20 bg-violet-500/10 px-2 py-1 text-[8px] font-black uppercase tracking-wider text-violet-300">
            ${nodes.length} nodes
          </span>

          <span class="rounded-full border border-sky-400/20 bg-sky-500/10 px-2 py-1 text-[8px] font-black uppercase tracking-wider text-sky-300">
            ${edges.length} edges
          </span>

        </div>

      </div>
    `
    }

    setStatus(value) {
        if (!this.hasStatusTarget) {
            return
        }

        this.statusTarget.textContent = value

        if (value === "LIVE") {
            this.statusTarget.className =
                "text-[9px] font-black uppercase tracking-widest text-emerald-500"
        } else if (value === "SYNCING") {
            this.statusTarget.className =
                "text-[9px] font-black uppercase tracking-widest text-amber-500"
        } else {
            this.statusTarget.className =
                "text-[9px] font-black uppercase tracking-widest text-red-500"
        }
    }

    humanize(value) {
        return String(value)
            .replaceAll("_", " ")
            .replace(/\b\w/g, (letter) => letter.toUpperCase())
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