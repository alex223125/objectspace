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

    // ============================================================
    // NORMALIZE ENTITY DATA
    // ============================================================

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

    // ============================================================
    // OVERVIEW METRICS
    // ============================================================

    updateMetrics(entities) {
        if (this.hasTotalTarget) {
            this.totalTarget.textContent = entities.length
        }

        const active = entities.filter(
            entity => entity.changes > 0
        ).length

        if (this.hasActiveTarget) {
            this.activeTarget.textContent = active
        }

        const totalChanges = entities.reduce(
            (sum, entity) => sum + entity.changes,
            0
        )

        if (this.hasChangesTarget) {
            this.changesTarget.textContent = totalChanges
        }

        const density = entities.length === 0
            ? 0
            : Math.round(
                totalChanges / entities.length
            )

        if (this.hasDensityTarget) {
            this.densityTarget.textContent = density
        }
    }

    // ============================================================
    // ENTITY LIST, SEARCH, FILTER AND SORT
    // ============================================================

    renderEntities(entities) {
        if (!this.hasEntityListTarget) {
            return
        }

        const query = this.hasSearchTarget
            ? this.searchTarget.value.trim().toLowerCase()
            : ""

        let filtered = entities.filter(entity => {
            const matchesSearch =
                !query ||
                entity.name.toLowerCase().includes(query) ||
                entity.category.toLowerCase().includes(query)

            const matchesFilter =
                this.currentFilter === "all" ||
                this.matchesFilter(entity, this.currentFilter)

            return matchesSearch && matchesFilter
        })

        filtered = this.sortEntities(filtered)

        if (filtered.length === 0) {
            this.entityListTarget.innerHTML = `
<div class="
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

        const maximumChanges = Math.max(
            ...entities.map(entity => entity.changes),
            1
        )

        this.entityListTarget.innerHTML = filtered
            .map((entity, index) =>
                this.entityCard(
                    entity,
                    index,
                    maximumChanges
                )
            )
            .join("")
    }

    // ============================================================
    // ENTITY CARD
    // ============================================================

    entityCard(entity, index, maximumChanges) {
        const activity = Math.round(
            (entity.changes / maximumChanges) * 100
        )

        // This is a heuristic indicator, not a validated
        // probability of risk.
        const risk = Math.min(
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

    <div class="flex items-start justify-between gap-4">
    <div class="flex min-w-0 items-center gap-3">
    <div class="
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
    <div class="
                                truncate
                                text-sm
                                font-black
                                text-slate-700
                            ">
        ${this.escapeHtml(entity.name)}
    </div>

    <div class="
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

<div class="
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

<!-- Activity comparison -->
<div class="mt-4">
    <div class="
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

    <div class="
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

<!-- Four explanatory metrics -->
<div class="mt-4 grid grid-cols-4 gap-2">

    ${this.miniMetric(
    "＋",
    entity.additions,
    "text-emerald-500",
    "additions",
    "Additions",
    "How many additions are recorded for this entity.",
    "The controller reads the additions field, or the added field if additions is absent. If neither is supplied, the value defaults to zero.",
    "The entity data supplied to this dashboard, normally prepared by the Rails backend from your application's comparison or change records.",
    "emerald"
)}

    ${this.miniMetric(
    "−",
    entity.removals,
    "text-rose-500",
    "removals",
    "Removals",
    "How many removals are recorded for this entity.",
    "The controller reads the removals field, or removed if removals is absent. If neither is supplied, the value defaults to zero.",
    "The entity data supplied to this dashboard. The exact records counted depend on the backend calculation that creates these fields.",
    "rose"
)}

    ${this.miniMetric(
    "↗",
    entity.movements,
    "text-sky-500",
    "movements",
    "Structural movements",
    "How many movements or relocation events are recorded for this entity.",
    "The controller reads the movements field, or moved if movements is absent. If neither is supplied, the value defaults to zero.",
    "The entity data supplied to this dashboard. The backend determines which structural changes qualify as movements.",
    "sky"
)}

    ${this.miniMetric(
    "⚠",
    entity.warnings,
    "text-amber-500",
    "warnings",
    "Review warnings",
    "How many warning signals are recorded for this entity.",
    "The controller reads the warnings field, or warning_count if warnings is absent. If neither is supplied, the value defaults to zero.",
    "The entity data supplied to this dashboard. The backend determines which conditions generate warnings and whether they require human review.",
    "amber"
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
                                "
                                title="This is a heuristic review signal based on warning and removal counts, not a validated risk probability.">

                                <span class="
                                    h-1.5
                                    w-1.5
                                    rounded-full
                                    bg-amber-400
                                "></span>

                                Elevated review signal

                            </div>
                        `
        : ""
}

</article>
`
    }

    // ============================================================
    // BEGINNER-FRIENDLY METRIC TOOLTIP
    // ============================================================

    miniMetric(
        icon,
        value,
        color,
        key,
        title,
        definition,
        calculation,
        source,
        theme
    ) {
        const tooltipId = `metric-${key}-tooltip`

        return `
<div
class="
group/metric
relative
min-w-0
rounded-xl
bg-slate-50
px-2
py-2
text-center
outline-none
transition
hover:bg-white
hover:ring-1
hover:ring-slate-200
focus-within:bg-white
focus-within:ring-2
focus-within:ring-violet-300
"
tabindex="0"
aria-label="${this.escapeHtml(
    `${title}. ${definition} How it is calculated: ${calculation} Data source: ${source}`
)}"
aria-describedby="${tooltipId}">

    <div class="
text-base
font-black
${color}
transition-transform
duration-200
group-hover/metric:scale-110
group-focus-within/metric:scale-110
">
${icon}
</div>

<div class="
                    mt-0.5
                    text-[10px]
                    font-black
                    text-slate-600
                ">
    ${this.escapeHtml(value)}
</div>

<div
    id="${tooltipId}"
    role="tooltip"
    class="
                        pointer-events-none
                        invisible
                        absolute
                        bottom-full
                        left-1/2
                        z-50
                        mb-3
                        w-64
                        max-w-[80vw]
                        -translate-x-1/2
                        translate-y-1
                        rounded-2xl
                        border
                        border-slate-200
                        bg-white
                        p-4
                        text-left
                        opacity-0
                        shadow-xl
                        shadow-slate-900/10
                        transition-all
                        duration-200
                        group-hover/metric:visible
                        group-hover/metric:translate-y-0
                        group-hover/metric:opacity-100
                        group-focus-within/metric:visible
                        group-focus-within/metric:translate-y-0
                        group-focus-within/metric:opacity-100
                    ">

    <!-- Tooltip heading -->
    <div class="flex items-start gap-2">
        <div class="
                            flex
                            h-8
                            w-8
                            shrink-0
                            items-center
                            justify-center
                            rounded-xl
                            bg-${theme}-50
                            text-base
                            ${color}
                        ">
            ${icon}
        </div>

        <div class="min-w-0 flex-1">
            <div class="
                                text-xs
                                font-black
                                text-slate-800
                            ">
                ${this.escapeHtml(title)}
            </div>

            <div class="
                                mt-0.5
                                text-[9px]
                                font-bold
                                uppercase
                                tracking-wider
                                text-slate-400
                            ">
                Metric guide
            </div>
        </div>
    </div>

    <!-- Plain-language definition -->
    <div class="mt-3">
        <div class="
                            text-[10px]
                            font-black
                            uppercase
                            tracking-wider
                            text-slate-500
                        ">
            What does it mean?
        </div>

        <p class="
                            mt-1
                            text-[11px]
                            leading-[1.65]
                            text-slate-600
                        ">
            ${this.escapeHtml(definition)}
        </p>
    </div>

    <!-- Calculation -->
    <div class="
                        mt-3
                        border-t
                        border-slate-100
                        pt-3
                    ">
        <div class="
                            text-[10px]
                            font-black
                            uppercase
                            tracking-wider
                            text-slate-500
                        ">
            How is it created?
        </div>

        <p class="
                            mt-1
                            text-[11px]
                            leading-[1.65]
                            text-slate-600
                        ">
            ${this.escapeHtml(calculation)}
        </p>
    </div>

    <!-- Data origin -->
    <div class="
                        mt-3
                        border-t
                        border-slate-100
                        pt-3
                    ">
        <div class="
                            text-[10px]
                            font-black
                            uppercase
                            tracking-wider
                            text-slate-500
                        ">
            Where does the data come from?
        </div>

        <p class="
                            mt-1
                            text-[11px]
                            leading-[1.65]
                            text-slate-600
                        ">
            ${this.escapeHtml(source)}
        </p>
    </div>

    <!-- Interpretation -->
    <div class="
                        mt-3
                        rounded-xl
                        bg-slate-50
                        p-2.5
                    ">
        <div class="
                            text-[10px]
                            font-black
                            text-slate-700
                        ">
            How should I interpret it?
        </div>

        <p class="
                            mt-1
                            text-[10px]
                            leading-[1.6]
                            text-slate-500
                        ">
            This is a recorded count, not automatically a measure of quality or importance. A zero can mean no events were recorded, or that the supplied data did not include this metric.
        </p>
    </div>

    <!-- Tooltip pointer -->
    <div class="
                        absolute
                        -bottom-1.5
                        left-1/2
                        h-3
                        w-3
                        -translate-x-1/2
                        rotate-45
                        border-b
                        border-r
                        border-slate-200
                        bg-white
                    "></div>

</div>
</div>
`
    }

    // ============================================================
    // ECOSYSTEM INSIGHTS
    // ============================================================

    renderInsights(entities) {
        if (!this.hasInsightsTarget) {
            return
        }

        const totalChanges = entities.reduce(
            (sum, entity) => sum + entity.changes,
            0
        )

        const mostActive = [...entities].sort(
            (a, b) => b.changes - a.changes
        )[0]

        const warningLeader = [...entities].sort(
            (a, b) => b.warnings - a.warnings
        )[0]

        const removalLeader = [...entities].sort(
            (a, b) => b.removals - a.removals
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

        this.insightsTarget.innerHTML = insights
            .slice(0, 4)
            .map(insight => `
<div class="
rounded-2xl
border
border-slate-100
bg-white
p-4
shadow-sm
">
<div class="flex items-start gap-3">
    <div class="
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
    <div class="
                                text-xs
                                font-black
                                text-slate-700
                            ">
        ${this.escapeHtml(insight.title)}
    </div>

    <p class="
                                mt-1
                                text-[10px]
                                leading-5
                                text-slate-400
                            ">
        ${this.escapeHtml(insight.description)}
    </p>
</div>
</div>
</div>
`)
            .join("")
    }

    // ============================================================
    // FILTER LOGIC
    // ============================================================

    matchesFilter(entity, filter) {
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

    // ============================================================
    // SORTING
    // ============================================================

    sortEntities(entities) {
        switch (this.currentSort) {
            case "name":
                return [...entities].sort(
                    (a, b) => a.name.localeCompare(b.name)
                )

            case "risk":
                return [...entities].sort(
                    (a, b) =>
                        (b.warnings + b.removals) -
                        (a.warnings + a.removals)
                )

            case "activity":
            default:
                return [...entities].sort(
                    (a, b) => b.changes - a.changes
                )
        }
    }

    // ============================================================
    // CONTROL ACTIONS
    // ============================================================

    filter(event) {
        this.currentFilter = event.currentTarget.value
        this.render()
    }

    sort(event) {
        this.currentSort = event.currentTarget.value
        this.render()
    }

    search() {
        this.render()
    }

    // ============================================================
    // HTML ESCAPING
    // ============================================================

    escapeHtml(value) {
        return String(value)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;")
    }
}
