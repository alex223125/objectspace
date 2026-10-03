import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "total",
        "active",
        "changes",
        "density",
        "insights",
        "entityList",
        "search",
        "filter",
        "sort"
    ]

    static values = {
        entities: Array
    }

    connect() {
        this.currentFilter = "all"
        this.currentSort = "activity"

        this.render()
    }

    render() {
        const entities = this.normalizedEntities()

        this.updateMetrics(entities)
        this.renderEntities(entities)
        this.renderInsights(entities)
    }

    normalizedEntities() {
        return Array.isArray(this.entitiesValue)
            ? this.entitiesValue.map((entity, index) => ({
                id: entity.id ?? index,

                name:
                    entity.name ||
                    entity.title ||
                    entity.label ||
                    `Entity ${index + 1}`,

                category:
                    entity.category ||
                    entity.type ||
                    "General",

                changes: Number(
                    entity.changes ??
                    entity.change_count ??
                    entity.changeCount ??
                    0
                ),

                additions: Number(
                    entity.additions ??
                    entity.added ??
                    0
                ),

                removals: Number(
                    entity.removals ??
                    entity.removed ??
                    0
                ),

                movements: Number(
                    entity.movements ??
                    entity.moved ??
                    0
                ),

                warnings: Number(
                    entity.warnings ??
                    entity.warning_count ??
                    0
                ),

                versions: Number(
                    entity.versions ??
                    entity.version_count ??
                    0
                ),

                evolution: Number(
                    entity.evolution ??
                    entity.evolution_score ??
                    0
                )
            }))
            : []
    }

    updateMetrics(entities) {
        if (this.hasTotalTarget) {
            this.totalTarget.textContent = entities.length
        }

        const active =
            entities.filter(
                entity => entity.changes > 0
            ).length

        if (this.hasActiveTarget) {
            this.activeTarget.textContent = active
        }

        const totalChanges =
            entities.reduce(
                (sum, entity) =>
                    sum + entity.changes,
                0
            )

        if (this.hasChangesTarget) {
            this.changesTarget.textContent =
                totalChanges
        }

        const density =
            entities.length === 0
                ? 0
                : Math.round(
                    totalChanges /
                    entities.length
                )

        if (this.hasDensityTarget) {
            this.densityTarget.textContent =
                density
        }
    }

    renderEntities(entities) {
        if (!this.hasEntityListTarget) {
            return
        }

        const query =
            this.hasSearchTarget
                ? this.searchTarget.value
                    .trim()
                    .toLowerCase()
                : ""

        let filtered = entities.filter(entity => {
            const matchesSearch =
                !query ||
                entity.name
                    .toLowerCase()
                    .includes(query) ||
                entity.category
                    .toLowerCase()
                    .includes(query)

            const matchesFilter =
                this.currentFilter === "all" ||
                this.matchesFilter(
                    entity,
                    this.currentFilter
                )

            return (
                matchesSearch &&
                matchesFilter
            )
        })

        filtered = this.sortEntities(
            filtered
        )

        if (filtered.length === 0) {
            this.entityListTarget.innerHTML = `
        <div
          class="
            rounded-2xl
            border
            border-dashed
            border-slate-200
            bg-slate-50
            p-8
            text-center
            text-sm
            text-slate-400
          ">

          No entities match this view.

        </div>
      `

            return
        }

        const maximumChanges =
            Math.max(
                ...entities.map(
                    entity => entity.changes
                ),
                1
            )

        this.entityListTarget.innerHTML =
            filtered
                .map(
                    (entity, index) =>
                        this.entityCard(
                            entity,
                            index,
                            maximumChanges
                        )
                )
                .join("")
    }

    entityCard(
        entity,
        index,
        maximumChanges
    ) {
        const activity =
            Math.round(
                (entity.changes /
                    maximumChanges) *
                100
            )

        const risk =
            Math.min(
                100,
                entity.warnings * 20 +
                entity.removals * 5
            )

        return `
      <article
        class="
          group
          rounded-2xl
          border
          border-slate-100
          bg-white
          p-4
          shadow-sm
          transition-all
          duration-300
          hover:-translate-y-0.5
          hover:border-violet-200
          hover:shadow-md
        "
        data-entity-id="${this.escapeHtml(entity.id)}">

        <div
          class="
            flex
            items-start
            justify-between
            gap-4
          ">

          <div
            class="
              flex
              min-w-0
              items-center
              gap-3
            ">

            <div
              class="
                flex
                h-10
                w-10
                shrink-0
                items-center
                justify-center
                rounded-xl
                bg-gradient-to-br
                from-violet-50
                to-indigo-50
                text-sm
                font-black
                text-violet-600
              ">

              ${index + 1}

            </div>

            <div class="min-w-0">

              <div
                class="
                  truncate
                  text-sm
                  font-black
                  text-slate-700
                ">

                ${this.escapeHtml(entity.name)}

              </div>

              <div
                class="
                  mt-0.5
                  text-[9px]
                  font-black
                  uppercase
                  tracking-wider
                  text-slate-300
                ">

                ${this.escapeHtml(entity.category)}

              </div>

            </div>

          </div>

          <div
            class="
              rounded-full
              bg-violet-50
              px-2.5
              py-1
              text-[9px]
              font-black
              text-violet-600
            ">

            ${entity.changes} changes

          </div>

        </div>


        <div class="mt-4">

          <div
            class="
              mb-1.5
              flex
              items-center
              justify-between
              text-[9px]
              font-black
              uppercase
              tracking-wider
              text-slate-400
            ">

            <span>Activity</span>

            <span>${activity}%</span>

          </div>

          <div
            class="
              h-1.5
              overflow-hidden
              rounded-full
              bg-slate-100
            ">

            <div
              class="
                h-full
                rounded-full
                bg-gradient-to-r
                from-violet-400
                to-indigo-400
                transition-all
                duration-700
              "
              style="width:${activity}%">
            </div>

          </div>

        </div>


        <div
          class="
            mt-4
            grid
            grid-cols-4
            gap-2
          ">

          ${this.miniMetric(
            "＋",
            entity.additions,
            "text-emerald-500"
        )}

          ${this.miniMetric(
            "−",
            entity.removals,
            "text-rose-500"
        )}

          ${this.miniMetric(
            "↗",
            entity.movements,
            "text-sky-500"
        )}

          ${this.miniMetric(
            "⚠",
            entity.warnings,
            "text-amber-500"
        )}

        </div>


        ${
            risk >= 50
                ? `
              <div
                class="
                  mt-3
                  flex
                  items-center
                  gap-2
                  text-[9px]
                  font-bold
                  text-amber-600
                ">

                <span
                  class="
                    h-1.5
                    w-1.5
                    rounded-full
                    bg-amber-400
                  ">
                </span>

                Elevated review signal

              </div>
            `
                : ""
        }

      </article>
    `
    }

    miniMetric(
        icon,
        value,
        color
    ) {
        return `
      <div
        class="
          rounded-xl
          bg-slate-50
          px-2
          py-2
          text-center
        ">

        <div
          class="
            text-[10px]
            font-black
            ${color}
          ">

          ${icon}

        </div>

        <div
          class="
            mt-0.5
            text-[10px]
            font-black
            text-slate-500
          ">

          ${value}

        </div>

      </div>
    `
    }

    renderInsights(entities) {
        if (!this.hasInsightsTarget) {
            return
        }

        const totalChanges =
            entities.reduce(
                (sum, entity) =>
                    sum + entity.changes,
                0
            )

        const mostActive =
            [...entities]
                .sort(
                    (a, b) =>
                        b.changes - a.changes
                )[0]

        const warningLeader =
            [...entities]
                .sort(
                    (a, b) =>
                        b.warnings - a.warnings
                )[0]

        const removalLeader =
            [...entities]
                .sort(
                    (a, b) =>
                        b.removals - a.removals
                )[0]

        const insights = []

        if (mostActive?.changes > 0) {
            insights.push({
                icon: "🔥",
                title: "Most active entity",
                description:
                    `${mostActive.name} currently contains the highest recorded change volume.`,
                color: "violet"
            })
        }

        if (warningLeader?.warnings > 0) {
            insights.push({
                icon: "⚠️",
                title: "Review signal",
                description:
                    `${warningLeader.name} has the highest warning count in this ecosystem view.`,
                color: "amber"
            })
        }

        if (removalLeader?.removals > 0) {
            insights.push({
                icon: "−",
                title: "Removal concentration",
                description:
                    `${removalLeader.name} has the highest removal activity.`,
                color: "rose"
            })
        }

        if (totalChanges > 0) {
            insights.push({
                icon: "◈",
                title: "Ecosystem activity",
                description:
                    `${totalChanges} total recorded changes are represented across the current entity set.`,
                color: "sky"
            })
        }

        if (insights.length === 0) {
            insights.push({
                icon: "✦",
                title: "Waiting for activity",
                description:
                    "Cross-entity intelligence will become more informative as comparison history grows.",
                color: "slate"
            })
        }

        this.insightsTarget.innerHTML =
            insights
                .slice(0, 4)
                .map(
                    insight => `
            <div
              class="
                rounded-2xl
                border
                border-slate-100
                bg-white
                p-4
                shadow-sm
              ">

              <div
                class="
                  flex
                  items-start
                  gap-3
                ">

                <div
                  class="
                    flex
                    h-9
                    w-9
                    shrink-0
                    items-center
                    justify-center
                    rounded-xl
                    bg-${insight.color}-50
                    text-sm
                  ">

                  ${insight.icon}

                </div>

                <div>

                  <div
                    class="
                      text-xs
                      font-black
                      text-slate-700
                    ">

                    ${this.escapeHtml(
                        insight.title
                    )}

                  </div>

                  <p
                    class="
                      mt-1
                      text-[10px]
                      leading-5
                      text-slate-400
                    ">

                    ${this.escapeHtml(
                        insight.description
                    )}

                  </p>

                </div>

              </div>

            </div>
          `
                )
                .join("")
    }

    matchesFilter(
        entity,
        filter
    ) {
        switch (filter) {
            case "active":
                return entity.changes > 0

            case "warnings":
                return entity.warnings > 0

            case "additions":
                return entity.additions > 0

            case "removals":
                return entity.removals > 0

            case "movement":
                return entity.movements > 0

            default:
                return true
        }
    }

    sortEntities(entities) {
        switch (this.currentSort) {
            case "name":
                return [...entities].sort(
                    (a, b) =>
                        a.name.localeCompare(
                            b.name
                        )
                )

            case "risk":
                return [...entities].sort(
                    (a, b) =>
                        (
                            b.warnings +
                            b.removals
                        ) -
                        (
                            a.warnings +
                            a.removals
                        )
                )

            case "activity":
            default:
                return [...entities].sort(
                    (a, b) =>
                        b.changes - a.changes
                )
        }
    }

    filter(event) {
        this.currentFilter =
            event.currentTarget.value

        this.render()
    }

    sort(event) {
        this.currentSort =
            event.currentTarget.value

        this.render()
    }

    search() {
        this.render()
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