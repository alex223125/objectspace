// frozen_string_literal: true

export default class ComparisonIntelligenceEngine {
    constructor(payload = {}) {
        this.payload = payload || {}
    }

    analyze() {
        const changes = this.extractChanges()

        const totals = {
            total: changes.length,
            changed: this.countType(changes, "changed"),
            moved: this.countType(changes, "moved"),
            added: this.countType(changes, "added"),
            removed: this.countType(changes, "removed"),
            warnings: this.countWarnings(changes)
        }

        const density = this.calculateChangeDensity(changes)
        const evolutionScore = this.calculateEvolutionScore(totals, density)
        const attention = this.buildAttention(changes)
        const paths = this.analyzePaths(changes)

        return {
            totals,
            density,
            evolutionScore,
            attention,
            paths,
            insight: this.buildInsight(
                totals,
                density,
                evolutionScore,
                attention
            )
        }
    }

    extractChanges() {
        if (Array.isArray(this.payload.changes)) {
            return this.payload.changes
        }

        if (Array.isArray(this.payload.differences)) {
            return this.payload.differences
        }

        if (Array.isArray(this.payload.items)) {
            return this.payload.items
        }

        return []
    }

    countType(changes, type) {
        return changes.filter(change => {
            return String(
                change.type ||
                change.change_type ||
                change.kind ||
                ""
            ).toLowerCase() === type
        }).length
    }

    countWarnings(changes) {
        return changes.filter(change => {
            return Boolean(
                change.warning ||
                change.identity_warning ||
                change.identityWarning ||
                change.risk === "high" ||
                change.risk === "critical"
            )
        }).length
    }

    calculateChangeDensity(changes) {
        if (changes.length === 0) {
            return 0
        }

        const paths = changes
            .map(change => change.path || change.field || change.key)
            .filter(Boolean)

        const uniquePaths = new Set(paths).size

        if (uniquePaths === 0) {
            return Math.min(100, changes.length * 10)
        }

        return Math.min(
            100,
            Math.round(
                (changes.length / uniquePaths) * 20
            )
        )
    }

    calculateEvolutionScore(totals, density) {
        if (totals.total === 0) {
            return 0
        }

        const structuralWeight =
            totals.changed * 8 +
            totals.moved * 10 +
            totals.added * 5 +
            totals.removed * 7

        const warningPenalty =
            totals.warnings * 8

        const raw =
            35 +
            Math.min(45, structuralWeight / totals.total) +
            density * 0.25 -
            warningPenalty

        return Math.max(
            0,
            Math.min(100, Math.round(raw))
        )
    }

    buildAttention(changes) {
        return changes
            .map((change, index) => {
                const risk = this.riskFor(change)
                const type = String(
                    change.type ||
                    change.change_type ||
                    change.kind ||
                    "changed"
                ).toLowerCase()

                const score =
                    risk +
                    this.typeWeight(type) +
                    (change.path ? 5 : 0)

                return {
                    id: change.id || index,
                    title:
                        change.title ||
                        change.label ||
                        change.path ||
                        `Change ${index + 1}`,
                    path: change.path || change.field || "",
                    type,
                    risk,
                    score,
                    reason: this.reasonFor(change, type)
                }
            })
            .sort((a, b) => b.score - a.score)
            .slice(0, 5)
    }

    analyzePaths(changes) {
        const counts = {}

        changes.forEach(change => {
            const path =
                change.path ||
                change.field ||
                change.key ||
                "Unspecified"

            counts[path] = (counts[path] || 0) + 1
        })

        return Object.entries(counts)
            .map(([path, count]) => ({
                path,
                count
            }))
            .sort((a, b) => b.count - a.count)
            .slice(0, 6)
    }

    riskFor(change) {
        const risk = String(
            change.risk ||
            change.severity ||
            ""
        ).toLowerCase()

        if (risk === "critical") return 40
        if (risk === "high") return 32
        if (risk === "medium") return 20
        if (risk === "low") return 8

        if (
            change.warning ||
            change.identity_warning ||
            change.identityWarning
        ) {
            return 35
        }

        return 5
    }

    typeWeight(type) {
        return {
            removed: 24,
            moved: 20,
            changed: 16,
            added: 10
        }[type] || 8
    }

    reasonFor(change, type) {
        if (
            change.warning ||
            change.identity_warning ||
            change.identityWarning
        ) {
            return "Identity or integrity warning requires review."
        }

        if (type === "removed") {
            return "Removal can affect historical continuity."
        }

        if (type === "moved") {
            return "Movement may indicate structural reorganization."
        }

        if (type === "changed") {
            return "Existing content has materially evolved."
        }

        if (type === "added") {
            return "New content may introduce an emerging concept."
        }

        return "Change detected in the comparison."
    }

    buildInsight(
        totals,
        density,
        evolutionScore,
        attention
    ) {
        if (totals.total === 0) {
            return {
                title: "No evolution detected",
                body:
                    "The selected versions currently show no detectable comparison changes.",
                tone: "neutral"
            }
        }

        if (totals.warnings > 0) {
            return {
                title: "Identity requires attention",
                body:
                    `${totals.warnings} warning signal(s) were detected. ` +
                    "Review these before interpreting broader evolution.",
                tone: "warning"
            }
        }

        if (density >= 70) {
            return {
                title: "High change concentration",
                body:
                    "Changes are concentrated across a relatively small set of paths. " +
                    "This may indicate focused structural evolution.",
                tone: "violet"
            }
        }

        if (evolutionScore >= 70) {
            return {
                title: "Strong version evolution",
                body:
                    "The comparison contains a substantial mixture of structural and content changes.",
                tone: "emerald"
            }
        }

        return {
            title: "Incremental evolution",
            body:
                "The comparison shows measurable change without a dominant structural disruption.",
            tone: "sky"
        }
    }
}