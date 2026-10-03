import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "total",
        "connected",
        "relationships",
        "xp",
        "level",
        "search",
        "filter",
        "entityList",
        "relationshipList",
        "insights",
        "progress",
        "empty"
    ]

    static values = {
        entities: Array,
        relationships: Array
    }

    connect() {
        this.currentFilter = "all"
        this.currentEntity = null

        this.render()
    }

    render() {
        const entities = this.normalizedEntities()
        const relationships = this.normalizedRelationships(entities)

        this.updateMetrics(
            entities,
            relationships
        )

        this.renderProgress(
            entities,
            relationships
        )

        this.renderInsights(
            entities,
            relationships
        )

        this.renderEntities(
            entities,
            relationships
        )

        this.renderRelationships(
            entities,
            relationships
        )
    }

    normalizedEntities() {
        if (!Array.isArray(this.entitiesValue)) {
            return []
        }

        return this.entitiesValue.map(
            (entity, index) => ({
                id:
                    entity.id ??
                    index,

                name:
                    entity.name ||
                    entity.title ||
                    entity.label ||
                    `Entity ${index + 1}`,

                category:
                    entity.category ||
                    entity.type ||
                    "General",

                description:
                    entity.description ||
                    "",

                activity:
                    Number(
                        entity.activity ??
                        entity.changes ??
                        entity.change_count ??
                        0
                    ),

                icon:
                    entity.icon ||
                    this.defaultIcon(
                        entity.category ||
                        entity.type
                    )
            })
        )
    }

    normalizedRelationships(
        entities
    ) {
        if (
            !Array.isArray(
                this.relationshipsValue
            )
        ) {
            return []
        }

        const validIds =
            new Set(
                entities.map(
                    entity =>
                        String(entity.id)
                )
            )

        return this.relationshipsValue
            .map(
                (relationship, index) => {
                    const source =
                        relationship.source_id ??
                        relationship.from_id ??
                        relationship.source ??
                        relationship.from

                    const target =
                        relationship.target_id ??
                        relationship.to_id ??
                        relationship.target ??
                        relationship.to

                    return {
                        id:
                            relationship.id ??
                            index,

                        source:
                            String(source),

                        target:
                            String(target),

                        type:
                            relationship.type ||
                            relationship.kind ||
                            relationship.relationship ||
                            "related",

                        label:
                            relationship.label ||
                            relationship.name ||
                            "",

                        strength:
                            Number(
                                relationship.strength ??
                                relationship.weight ??
                                1
                            ),

                        activity:
                            Number(
                                relationship.activity ??
                                relationship.changes ??
                                0
                            )
                    }
                }
            )
            .filter(
                relationship =>
                    validIds.has(
                        relationship.source
                    ) &&
                    validIds.has(
                        relationship.target
                    )
            )
    }

    updateMetrics(
        entities,
        relationships
    ) {
        if (this.hasTotalTarget) {
            this.totalTarget.textContent =
                entities.length
        }

        const connectedIds =
            new Set()

        relationships.forEach(
            relationship => {
                connectedIds.add(
                    relationship.source
                )

                connectedIds.add(
                    relationship.target
                )
            }
        )

        if (this.hasConnectedTarget) {
            this.connectedTarget.textContent =
                connectedIds.size
        }

        if (this.hasRelationshipsTarget) {
            this.relationshipsTarget.textContent =
                relationships.length
        }
    }

    renderProgress(
        entities,
        relationships
    ) {
        const xp =
            Math.min(
                1000,
                entities.length * 10 +
                relationships.length * 20
            )

        const level =
            Math.max(
                1,
                Math.floor(xp / 100) + 1
            )

        const progress =
            xp % 100

        if (this.hasXpTarget) {
            this.xpTarget.textContent =
                `${xp} XP`
        }

        if (this.hasLevelTarget) {
            this.levelTarget.textContent =
                `Level ${level}`
        }

        if (this.hasProgressTarget) {
            this.progressTarget.style.width =
                `${progress}%`
        }
    }

    renderInsights(
        entities,
        relationships
    ) {
        if (!this.hasInsightsTarget) {
            return
        }

        if (
            entities.length === 0
        ) {
            this.insightsTarget.innerHTML =
                this.insightCard(
                    "🌱",
                    "Ecosystem ready",
                    "Add entities to begin building cross-entity intelligence.",
                    "emerald"
                )

            return
        }

        if (
            relationships.length === 0
        ) {
            this.insightsTarget.innerHTML =
                [
                    this.insightCard(
                        "🔗",
                        "Relationship layer ready",
                        "Your ecosystem entities are ready to be connected.",
                        "sky"
                    ),

                    this.insightCard(
                        "🧭",
                        "Start exploring",
                        "Relationship data will unlock ecosystem-level discovery.",
                        "orange"
                    ),

                    this.insightCard(
                        "✨",
                        "Explorer XP",
                        "Discovering connected entities increases the intelligence layer.",
                        "violet"
                    )
                ].join("")

            return
        }

        const busiest =
            this.entityRelationshipCounts(
                entities,
                relationships
            )
                .sort(
                    (a, b) =>
                        b.count - a.count
                )[0]

        const strongest =
            [...relationships]
                .sort(
                    (a, b) =>
                        b.strength - a.strength
                )[0]

        const typeCounts = {}

        relationships.forEach(
            relationship => {
                typeCounts[
                    relationship.type
                    ] =
                    (
                        typeCounts[
                            relationship.type
                            ] || 0
                    ) + 1
            }
        )

        const dominantType =
            Object.entries(
                typeCounts
            )
                .sort(
                    (a, b) =>
                        b[1] - a[1]
                )[0]

        const busiestEntity =
            busiest
                ? this.findEntity(
                    entities,
                    busiest.id
                )
                : null

        const strongestSource =
            strongest
                ? this.findEntity(
                    entities,
                    strongest.source
                )
                : null

        const strongestTarget =
            strongest
                ? this.findEntity(
                    entities,
                    strongest.target
                )
                : null

        const cards = []

        if (busiestEntity) {
            cards.push(
                this.insightCard(
                    "🔥",
                    "Relationship hub",
                    `${busiestEntity.name} currently connects to ${busiest.count} other entities.`,
                    "orange"
                )
            )
        }

        if (
            strongestSource &&
            strongestTarget
        ) {
            cards.push(
                this.insightCard(
                    "↗",
                    "Strongest connection",
                    `${strongestSource.name} → ${strongestTarget.name} has the strongest recorded relationship signal.`,
                    "violet"
                )
            )
        }

        if (dominantType) {
            cards.push(
                this.insightCard(
                    "◈",
                    "Dominant relationship",
                    `${dominantType[0]} represents ${dominantType[1]} recorded connections.`,
                    "sky"
                )
            )
        }

        cards.push(
            this.insightCard(
                "🧭",
                "Discovery unlocked",
                `${relationships.length} relationships are currently available for exploration.`,
                "emerald"
            )
        )

        this.insightsTarget.innerHTML =
            cards
                .slice(0, 4)
                .join("")
    }

    renderEntities(
        entities,
        relationships
    ) {
        if (!this.hasEntityListTarget) {
            return
        }

        const query =
            this.hasSearchTarget
                ? this.searchTarget.value
                    .trim()
                    .toLowerCase()
                : ""

        let filtered =
            entities.filter(
                entity => {
                    const connected =
                        relationships.some(
                            relationship =>
                                relationship.source ===
                                String(entity.id) ||
                                relationship.target ===
                                String(entity.id)
                        )

                    const matchesSearch =
                        !query ||
                        entity.name
                            .toLowerCase()
                            .includes(query) ||
                        entity.category
                            .toLowerCase()
                            .includes(query)

                    const matchesFilter =
                        this.currentFilter ===
                        "all" ||
                        (
                            this.currentFilter ===
                            "connected" &&
                            connected
                        ) ||
                        (
                            this.currentFilter ===
                            "isolated" &&
                            !connected
                        )

                    return (
                        matchesSearch &&
                        matchesFilter
                    )
                }
            )

        if (
            filtered.length === 0
        ) {
            this.entityListTarget.innerHTML =
                this.emptyState(
                    "No entities match this view."
                )

            return
        }

        this.entityListTarget.innerHTML =
            filtered
                .map(
                    entity =>
                        this.entityCard(
                            entity,
                            relationships
                        )
                )
                .join("")
    }

    renderRelationships(
        entities,
        relationships
    ) {
        if (
            !this.hasRelationshipListTarget
        ) {
            return
        }

        if (
            relationships.length === 0
        ) {
            this.relationshipListTarget.innerHTML =
                this.emptyState(
                    "No cross-entity relationships have been connected yet."
                )

            return
        }

        this.relationshipListTarget.innerHTML =
            relationships
                .slice(0, 30)
                .map(
                    relationship =>
                        this.relationshipCard(
                            relationship,
                            entities
                        )
                )
                .join("")
    }

    entityCard(
        entity,
        relationships
    ) {
        const connections =
            relationships.filter(
                relationship =>
                    relationship.source ===
                    String(entity.id) ||
                    relationship.target ===
                    String(entity.id)
            ).length

        const active =
            this.currentEntity ===
            String(entity.id)

        return `
      <button
        type="button"
        data-entity-id="${this.escapeHtml(entity.id)}"
        data-action="click->entity-relationship-intelligence#focusEntity"
        class="
          group
          w-full
          rounded-[24px]
          border-2
          ${active
            ? "border-orange-300 bg-orange-50/60 shadow-md shadow-orange-100"
            : "border-slate-100 bg-white"}
          p-4
          text-left
          shadow-sm
          transition-all
          duration-300
          hover:-translate-y-0.5
          hover:border-orange-200
          hover:shadow-md
        ">

        <div
          class="
            flex
            items-center
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
                bg-gradient-to-br
                from-orange-50
                to-amber-50
                text-lg
                shadow-sm
              ">

              ${this.escapeHtml(
            entity.icon
        )}

            </div>

            <div class="min-w-0">

              <div
                class="
                  truncate
                  text-xs
                  font-black
                  text-slate-700
                ">

                ${this.escapeHtml(
            entity.name
        )}

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

                ${this.escapeHtml(
            entity.category
        )}

              </div>

            </div>

          </div>

          <span
            class="
              shrink-0
              rounded-full
              bg-orange-50
              px-2.5
              py-1
              text-[9px]
              font-black
              text-orange-600
            ">

            ${connections}

          </span>

        </div>

        <div class="mt-4">

          <div
            class="
              flex
              items-center
              justify-between
              text-[9px]
              font-black
              uppercase
              tracking-wider
              text-slate-400
            ">

            <span>
              Relationship activity
            </span>

            <span>
              ${connections > 0 ? "CONNECTED" : "ISOLATED"}
            </span>

          </div>

          <div
            class="
              mt-2
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
              "
              style="
                width:${Math.min(
            100,
            connections * 20
        )}%;
              ">
            </div>

          </div>

        </div>

      </button>
    `
    }

    relationshipCard(
        relationship,
        entities
    ) {
        const source =
            this.findEntity(
                entities,
                relationship.source
            )

        const target =
            this.findEntity(
                entities,
                relationship.target
            )

        if (!source || !target) {
            return ""
        }

        return `
      <article
        class="
          rounded-[24px]
          border-2
          border-slate-100
          bg-white
          p-4
          shadow-sm
          transition-all
          duration-300
          hover:border-violet-200
          hover:shadow-md
        ">

        <div
          class="
            flex
            items-center
            gap-3
          ">

          <div
            class="
              min-w-0
              flex-1
              rounded-2xl
              bg-orange-50/70
              p-3
            ">

            <div
              class="
                truncate
                text-[10px]
                font-black
                text-slate-700
              ">

              ${this.escapeHtml(
            source.name
        )}

            </div>

            <div
              class="
                mt-1
                text-[8px]
                font-bold
                uppercase
                tracking-widest
                text-orange-400
              ">

              ${this.escapeHtml(
            source.category
        )}

            </div>

          </div>

          <div
            class="
              flex
              shrink-0
              flex-col
              items-center
              gap-1
            ">

            <span
              class="
                text-lg
                font-black
                text-violet-400
              ">

              →

            </span>

            <span
              class="
                rounded-full
                bg-violet-50
                px-2
                py-0.5
                text-[7px]
                font-black
                uppercase
                tracking-wider
                text-violet-500
              ">

              ${this.escapeHtml(
            relationship.type
        )}

            </span>

          </div>

          <div
            class="
              min-w-0
              flex-1
              rounded-2xl
              bg-emerald-50/70
              p-3
            ">

            <div
              class="
                truncate
                text-[10px]
                font-black
                text-slate-700
              ">

              ${this.escapeHtml(
            target.name
        )}

            </div>

            <div
              class="
                mt-1
                text-[8px]
                font-bold
                uppercase
                tracking-widest
                text-emerald-500
              ">

              ${this.escapeHtml(
            target.category
        )}

            </div>

          </div>

        </div>

        <div
          class="
            mt-3
            flex
            items-center
            justify-between
          ">

          <span
            class="
              text-[9px]
              font-medium
              text-slate-400
            ">

            ${
            relationship.label
                ? this.escapeHtml(
                    relationship.label
                )
                : "Cross-entity connection"
        }

          </span>

          <span
            class="
              rounded-full
              bg-slate-50
              px-2
              py-1
              text-[8px]
              font-black
              text-slate-400
            ">

            Strength ${relationship.strength}

          </span>

        </div>

      </article>
    `
    }

    focusEntity(event) {
        const id =
            event.currentTarget.dataset.entityId

        this.currentEntity =
            this.currentEntity === id
                ? null
                : id

        this.render()
    }

    filter(event) {
        this.currentFilter =
            event.currentTarget.value

        this.render()
    }

    search() {
        this.render()
    }

    entityRelationshipCounts(
        entities,
        relationships
    ) {
        return entities.map(
            entity => ({
                id: String(entity.id),
                count:
                relationships.filter(
                    relationship =>
                        relationship.source ===
                        String(entity.id) ||
                        relationship.target ===
                        String(entity.id)
                ).length
            })
        )
    }

    findEntity(
        entities,
        id
    ) {
        return entities.find(
            entity =>
                String(entity.id) ===
                String(id)
        )
    }

    defaultIcon(
        category
    ) {
        const value =
            String(
                category || ""
            ).toLowerCase()

        if (
            value.includes("problem")
        ) {
            return "🎯"
        }

        if (
            value.includes("method")
        ) {
            return "🧩"
        }

        if (
            value.includes("algorithm")
        ) {
            return "⚙️"
        }

        if (
            value.includes("technology")
        ) {
            return "💻"
        }

        if (
            value.includes("architecture")
        ) {
            return "🏗️"
        }

        return "◈"
    }

    insightCard(
        icon,
        title,
        description,
        color
    ) {
        return `
      <div
        class="
          rounded-[22px]
          border-2
          border-${color}-100
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
              h-10
              w-10
              shrink-0
              items-center
              justify-center
              rounded-2xl
              bg-${color}-50
              text-base
            ">

            ${icon}

          </div>

          <div>

            <div
              class="
                text-xs
                font-black
                text-slate-700
              ">

              ${this.escapeHtml(
            title
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
            description
        )}

            </p>

          </div>

        </div>

      </div>
    `
    }

    emptyState(
        message
    ) {
        return `
      <div
        class="
          rounded-[24px]
          border-2
          border-dashed
          border-slate-200
          bg-slate-50/70
          p-8
          text-center
          text-xs
          font-bold
          text-slate-400
        ">

        ${this.escapeHtml(
            message
        )}

      </div>
    `
    }

    escapeHtml(value) {
        return String(value)
            .replaceAll(
                "&",
                "&amp;"
            )
            .replaceAll(
                "<",
                "&lt;"
            )
            .replaceAll(
                ">",
                "&gt;"
            )
            .replaceAll(
                '"',
                "&quot;"
            )
            .replaceAll(
                "'",
                "&#039;"
            )
    }
}