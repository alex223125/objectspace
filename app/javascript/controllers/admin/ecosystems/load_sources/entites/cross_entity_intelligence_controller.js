import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "total",
        "active",
        "relationships",
        "density",
        "xp",
        "level",
        "progress",
        "insights",
        "entities",
        "search",
        "filter",
        "sort",
        "relationshipList",
        "path"
    ]

    static values = {
        entities: Array,
        relationships: Array
    }

    connect() {
        this.currentFilter = "all"
        this.currentSort = "activity"
        this.render()
    }

    render() {
        const entities = this.normalizedEntities()
        const relationships = this.normalizedRelationships(entities)

        this.updateMetrics(entities, relationships)
        this.renderInsights(entities, relationships)
        this.renderEntities(entities, relationships)
        this.renderRelationships(entities, relationships)
        this.renderDiscoveryPath(entities, relationships)
    }

    normalizedEntities() {
        if (!Array.isArray(this.entitiesValue)) {
            return []
        }

        return this.entitiesValue.map((entity, index) => ({
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
            ),

            connections: Number(
                entity.connections ??
                entity.connection_count ??
                0
            )
        }))
    }

    normalizedRelationships(entities) {
        if (Array.isArray(this.relationshipsValue) &&
            this.relationshipsValue.length > 0) {
            return this.relationshipsValue.map(
                (relationship, index) => ({
                    id:
                        relationship.id ??
                        index,

                    source:
                        relationship.source ??
                        relationship.from ??
                        relationship.source_id,

                    target:
                        relationship.target ??
                        relationship.to ??
                        relationship.target_id,

                    type:
                        relationship.type ??
                        relationship.kind ??
                        "related",

                    weight: Number(
                        relationship.weight ??
                        relationship.strength ??
                        1
                    ),

                    label:
                        relationship.label ??
                        relationship.name ??
                        relationship.type ??
                        "Related"
                })
            )
        }

        return this.deriveRelationships(entities)
    }

    deriveRelationships(entities) {
        const relationships = []

        for (let index = 0; index < entities.length - 1; index++) {
            const current = entities[index]
            const next = entities[index + 1]

            relationships.push({
                id: `derived-${index}`,
                source: current.id,
                target: next.id,
                type: "ecosystem",
                weight: Math.max(
                    1,
                    Math.round(
                        (
                            current.changes +
                            next.changes
                        ) / 10
                    )
                ),
                label: "Ecosystem connection"
            })
        }

        return relationships
    }

    updateMetrics(entities, relationships) {
        const active = entities.filter(
            entity =>
                entity.changes > 0 ||
                entity.connections > 0
        ).length

        const totalWeight = relationships.reduce(
            (sum, relationship) =>
                sum + relationship.weight,
            0
        )

        const possible =
            entities.length > 1
                ? entities.length * (entities.length - 1) / 2
                : 0

        const density =
            possible === 0
                ? 0
                : Math.min(
                    100,
                    Math.round(
                        (relationships.length / possible) * 100
                    )
                )

        const explorationXp =
            entities.reduce(
                (sum, entity) =>
                    sum +
                    entity.changes +
                    entity.connections * 5,
                0
            )

        const level =
            Math.max(
                1,
                Math.floor(explorationXp / 100) + 1
            )

        const levelProgress =
            explorationXp % 100

        if (this.hasTotalTarget) {
            this.totalTarget.textContent =
                entities.length
        }

        if (this.hasActiveTarget) {
            this.activeTarget.textContent =
                active
        }

        if (this.hasRelationshipsTarget) {
            this.relationshipsTarget.textContent =
                relationships.length
        }

        if (this.hasDensityTarget) {
            this.densityTarget.textContent =
                `${density}%`
        }

        if (this.hasXpTarget) {
            this.xpTarget.textContent =
                explorationXp
        }

        if (this.hasLevelTarget) {
            this.levelTarget.textContent =
                level
        }

        if (this.hasProgressTarget) {
            this.progressTarget.style.width =
                `${levelProgress}%`

            this.progressTarget.setAttribute(
                "aria-valuenow",
                levelProgress
            )
        }

        return {
            totalWeight,
            density,
            explorationXp,
            level,
            levelProgress
        }
    }

    renderInsights(entities, relationships) {
        if (!this.hasInsightsTarget) {
            return
        }

        const insights = []

        const mostConnected =
            [...entities]
                .sort(
                    (a, b) =>
                        this.connectionScore(b, relationships) -
                        this.connectionScore(a, relationships)
                )[0]

        const mostActive =
            [...entities]
                .sort(
                    (a, b) =>
                        b.changes - a.changes
                )[0]

        const strongestRelationship =
            [...relationships]
                .sort(
                    (a, b) =>
                        b.weight - a.weight
                )[0]

        if (mostConnected) {
            insights.push({
                icon: "🕸️",
                title: "Ecosystem hub",
                description:
                    `${mostConnected.name} connects with ${this.connectionScore(mostConnected, relationships)} relationship${this.connectionScore(mostConnected, relationships) === 1 ? "" : "s"}.`,
                color: "orange"
            })
        }

        if (strongestRelationship) {
            const source =
                this.entityById(
                    entities,
                    strongestRelationship.source
                )

            const target =
                this.entityById(
                    entities,
                    strongestRelationship.target
                )

            if (source && target) {
                insights.push({
                    icon: "⚡",
                    title: "Strongest connection",
                    description:
                        `${source.name} ↔ ${target.name} has the strongest recorded relationship signal.`,
                    color: "violet"
                })
            }
        }

        if (mostActive?.changes > 0) {
            insights.push({
                icon: "🔥",
                title: "Activity hotspot",
                description:
                    `${mostActive.name} currently carries the highest change activity.`,
                color: "amber"
            })
        }

        if (relationships.length > 0) {
            insights.push({
                icon: "🧭",
                title: "Discovery opportunity",
                description:
                    `${relationships.length} ecosystem connections can be explored from the current knowledge set.`,
                color: "sky"
            })
        }

        if (insights.length === 0) {
            insights.push({
                icon: "✦",
                title: "Ecosystem is forming",
                description:
                    "As entities and relationships accumulate, cross-entity intelligence will become richer.",
                color: "emerald"
            })
        }

        this.insightsTarget.innerHTML =
            insights
                .slice(0, 4)
                .map(
                    insight => `
            <article
              class="
                rounded-[24px]
                border
                border-slate-100
                bg-white
                p-4
                shadow-sm
                transition-all
                duration-300
                hover:-translate-y-0.5
                hover:shadow-md
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
                    h-10
                    w-10
                    shrink-0
                    items-center
                    justify-center
                    rounded-2xl
                    bg-${insight.color}-50
                    text-lg
                  ">

                  ${insight.icon}

                </div>

                <div class="min-w-0">

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

            </article>
          `
                )
                .join("")
    }

    renderEntities(entities, relationships) {
        if (!this.hasEntitiesTarget) {
            return
        }

        const query =
            this.hasSearchTarget
                ? this.searchTarget.value
                    .trim()
                    .toLowerCase()
                : ""

        let filtered =
            entities.filter(entity => {
                const searchMatch =
                    !query ||
                    entity.name
                        .toLowerCase()
                        .includes(query) ||
                    entity.category
                        .toLowerCase()
                        .includes(query)

                const filterMatch =
                    this.matchesFilter(
                        entity,
                        relationships,
                        this.currentFilter
                    )

                return searchMatch && filterMatch
            })

        filtered =
            this.sortEntities(
                filtered,
                relationships
            )

        if (filtered.length === 0) {
            this.entitiesTarget.innerHTML = `
        <div
          class="
            col-span-full
            rounded-[24px]
            border-2
            border-dashed
            border-slate-200
            bg-slate-50
            p-8
            text-center
            text-sm
            font-bold
            text-slate-400
          ">

          No entities match this exploration view.

        </div>
      `

            return
        }

        const maximumScore =
            Math.max(
                ...entities.map(
                    entity =>
                        this.entityActivityScore(
                            entity,
                            relationships
                        )
                ),
                1
            )

        this.entitiesTarget.innerHTML =
            filtered
                .map(
                    (entity, index) =>
                        this.entityCard(
                            entity,
                            index,
                            relationships,
                            maximumScore
                        )
                )
                .join("")
    }

    entityCard(
        entity,
        index,
        relationships,
        maximumScore
    ) {
        const connections =
            this.connectionScore(
                entity,
                relationships
            )

        const score =
            this.entityActivityScore(
                entity,
                relationships
            )

        const percentage =
            Math.round(
                (score / maximumScore) * 100
            )

        const xp =
            entity.changes +
            connections * 5

        return `
      <article
        class="
          group
          rounded-[26px]
          border-2
          border-slate-100
          bg-white
          p-5
          shadow-sm
          transition-all
          duration-300
          hover:-translate-y-1
          hover:border-orange-200
          hover:shadow-lg
          hover:shadow-orange-100/40
        "
        data-entity-id="${this.escapeHtml(entity.id)}">

        <div
          class="
            flex
            items-start
            justify-between
            gap-3
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
                h-11
                w-11
                shrink-0
                items-center
                justify-center
                rounded-2xl
                border-2
                border-orange-200
                bg-orange-50
                text-xs
                font-black
                text-orange-600
                shadow-sm
              ">

              ${String(index + 1).padStart(2, "0")}

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
                  mt-1
                  text-[9px]
                  font-black
                  uppercase
                  tracking-widest
                  text-slate-300
                ">

                ${this.escapeHtml(entity.category)}

              </div>

            </div>

          </div>

          <span
            class="
              rounded-full
              bg-orange-50
              px-2.5
              py-1
              text-[9px]
              font-black
              text-orange-600
            ">

            +${xp} XP

          </span>

        </div>

        <div class="mt-5">

          <div
            class="
              mb-1.5
              flex
              items-center
              justify-between
              text-[9px]
              font-black
              uppercase
              tracking-widest
              text-slate-400
            ">

            <span>Influence</span>

            <span>${percentage}%</span>

          </div>

          <div
            class="
              h-2
              overflow-hidden
              rounded-full
              bg-slate-100
            ">

            <div
              class="
                h-full
                rounded-full
                bg-gradient-to-r
                from-orange-400
                via-amber-400
                to-emerald-400
                transition-all
                duration-700
              "
              style="width:${percentage}%">
            </div>

          </div>

        </div>

        <div
          class="
            mt-4
            grid
            grid-cols-3
            gap-2
          ">

          ${this.metric(
            "Changes",
            entity.changes,
            "text-violet-500"
        )}

          ${this.metric(
            "Links",
            connections,
            "text-sky-500"
        )}

          ${this.metric(
            "Versions",
            entity.versions,
            "text-emerald-500"
        )}

        </div>

        ${
            connections >= 3
                ? `
              <div
                class="
                  mt-4
                  flex
                  items-center
                  gap-2
                  text-[9px]
                  font-black
                  uppercase
                  tracking-wider
                  text-orange-500
                ">

                <span
                  class="
                    h-2
                    w-2
                    rounded-full
                    bg-orange-400
                    shadow-[0_0_8px_rgba(251,146,60,0.7)]
                  ">
                </span>

                Ecosystem hub

              </div>
            `
                : ""
        }

      </article>
    `
    }

    metric(label, value, color) {
        return `
      <div
        class="
          rounded-2xl
          bg-slate-50
          px-2
          py-2.5
          text-center
        ">

        <div
          class="
            text-[9px]
            font-black
            uppercase
            tracking-wider
            text-slate-300
          ">

          ${label}

        </div>

        <div
          class="
            mt-1
            text-sm
            font-black
            ${color}
          ">

          ${value}

        </div>

      </div>
    `
    }

    renderRelationships(entities, relationships) {
        if (!this.hasRelationshipListTarget) {
            return
        }

        if (relationships.length === 0) {
            this.relationshipListTarget.innerHTML = `
        <div
          class="
            rounded-2xl
            bg-slate-50
            p-6
            text-center
            text-xs
            font-bold
            text-slate-400
          ">

          No relationships recorded yet.

        </div>
      `

            return
        }

        const sorted =
            [...relationships]
                .sort(
                    (a, b) =>
                        b.weight - a.weight
                )
                .slice(0, 8)

        const maximum =
            Math.max(
                ...sorted.map(
                    relationship =>
                        relationship.weight
                ),
                1
            )

        this.relationshipListTarget.innerHTML =
            sorted
                .map(
                    relationship => {
                        const source =
                            this.entityById(
                                entities,
                                relationship.source
                            )

                        const target =
                            this.entityById(
                                entities,
                                relationship.target
                            )

                        if (!source || !target) {
                            return ""
                        }

                        const strength =
                            Math.round(
                                (
                                    relationship.weight /
                                    maximum
                                ) * 100
                            )

                        return `
              <div
                class="
                  rounded-2xl
                  border
                  border-slate-100
                  bg-white
                  p-4
                ">

                <div
                  class="
                    flex
                    items-center
                    justify-between
                    gap-3
                  ">

                  <div class="min-w-0">

                    <div
                      class="
                        truncate
                        text-xs
                        font-black
                        text-slate-700
                      ">

                      ${this.escapeHtml(source.name)}

                      <span
                        class="mx-1 text-orange-400">
                        ↔
                      </span>

                      ${this.escapeHtml(target.name)}

                    </div>

                    <div
                      class="
                        mt-1
                        text-[9px]
                        font-bold
                        uppercase
                        tracking-widest
                        text-slate-300
                      ">

                      ${this.escapeHtml(
                            relationship.label
                        )}

                    </div>

                  </div>

                  <span
                    class="
                      shrink-0
                      rounded-full
                      bg-violet-50
                      px-2.5
                      py-1
                      text-[9px]
                      font-black
                      text-violet-600
                    ">

                    ${relationship.weight}

                  </span>

                </div>

                <div
                  class="
                    mt-3
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
                      to-sky-400
                    "
                    style="width:${strength}%">
                  </div>

                </div>

              </div>
            `
                    }
                )
                .join("")
    }

    renderDiscoveryPath(entities, relationships) {
        if (!this.hasPathTarget) {
            return
        }

        const ordered =
            [...entities]
                .sort(
                    (a, b) =>
                        this.entityActivityScore(
                            b,
                            relationships
                        ) -
                        this.entityActivityScore(
                            a,
                            relationships
                        )
                )
                .slice(0, 4)

        if (ordered.length === 0) {
            this.pathTarget.innerHTML = ""
            return
        }

        this.pathTarget.innerHTML =
            ordered
                .map(
                    (entity, index) => `
            <div
              class="
                relative
                flex
                flex-1
                flex-col
                items-center
              ">

              ${
                        index < ordered.length - 1
                            ? `
                    <div
                      class="
                        absolute
                        left-1/2
                        top-5
                        hidden
                        h-0.5
                        w-full
                        bg-gradient-to-r
                        from-orange-200
                        to-sky-200
                        md:block
                      ">
                    </div>
                  `
                            : ""
                    }

              <div
                class="
                  relative
                  z-10
                  flex
                  h-10
                  w-10
                  items-center
                  justify-center
                  rounded-2xl
                  border-2
                  border-orange-200
                  bg-orange-50
                  text-[10px]
                  font-black
                  text-orange-600
                  shadow-sm
                ">

                ${index + 1}

              </div>

              <div
                class="
                  mt-3
                  max-w-[130px]
                  truncate
                  text-center
                  text-[10px]
                  font-black
                  text-slate-600
                ">

                ${this.escapeHtml(entity.name)}

              </div>

            </div>
          `
                )
                .join("")
    }

    connectionScore(entity, relationships) {
        return relationships.filter(
            relationship =>
                String(relationship.source) ===
                String(entity.id) ||
                String(relationship.target) ===
                String(entity.id)
        ).length
    }

    entityActivityScore(entity, relationships) {
        return (
            entity.changes +
            this.connectionScore(
                entity,
                relationships
            ) * 10 +
            entity.evolution
        )
    }

    entityById(entities, id) {
        return entities.find(
            entity =>
                String(entity.id) === String(id)
        )
    }

    matchesFilter(
        entity,
        relationships,
        filter
    ) {
        switch (filter) {
            case "hubs":
                return this.connectionScore(
                    entity,
                    relationships
                ) >= 3

            case "active":
                return entity.changes > 0

            case "evolving":
                return entity.evolution > 0

            case "connected":
                return this.connectionScore(
                    entity,
                    relationships
                ) > 0

            default:
                return true
        }
    }

    sortEntities(entities, relationships) {
        switch (this.currentSort) {
            case "connections":
                return [...entities].sort(
                    (a, b) =>
                        this.connectionScore(
                            b,
                            relationships
                        ) -
                        this.connectionScore(
                            a,
                            relationships
                        )
                )

            case "name":
                return [...entities].sort(
                    (a, b) =>
                        a.name.localeCompare(b.name)
                )

            case "activity":
            default:
                return [...entities].sort(
                    (a, b) =>
                        this.entityActivityScore(
                            b,
                            relationships
                        ) -
                        this.entityActivityScore(
                            a,
                            relationships
                        )
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