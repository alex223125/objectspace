import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "summary",
        "content",
        "movements",
        "additions",
        "removals",
        "warnings",
        "empty",
        "filter"
    ]

    connect() {
        this.payload = this.readPayload()
        this.activeFilter = "all"

        this.render()
    }

    readPayload() {
        const element =
            this.element.querySelector(
                "[data-entity-diff-payload]"
            )

        if (!element) {
            return this.emptyPayload()
        }

        try {
            const payload =
                JSON.parse(
                    element.textContent || "{}"
                )

            return {
                summary:
                    payload.summary || {},

                changes:
                    Array.isArray(
                        payload.changes
                    )
                        ? payload.changes
                        : [],

                movements:
                    Array.isArray(
                        payload.movements
                    )
                        ? payload.movements
                        : [],

                additions:
                    Array.isArray(
                        payload.additions
                    )
                        ? payload.additions
                        : [],

                removals:
                    Array.isArray(
                        payload.removals
                    )
                        ? payload.removals
                        : [],

                warnings:
                    Array.isArray(
                        payload.warnings
                    )
                        ? payload.warnings
                        : [],

                total:
                    Number(
                        payload.total || 0
                    )
            }
        } catch (error) {
            console.error(
                "Unable to parse entity diff payload.",
                error
            )

            return this.emptyPayload()
        }
    }

    emptyPayload() {
        return {
            summary: {
                total: 0,
                changes: 0,
                movements: 0,
                additions: 0,
                removals: 0,
                warnings: 0
            },

            changes: [],
            movements: [],
            additions: [],
            removals: [],
            warnings: [],
            total: 0
        }
    }

    render() {
        this.renderSummary()

        this.renderSection(
            this.contentTarget,
            this.payload.changes,
            "content_change"
        )

        this.renderSection(
            this.movementsTarget,
            this.payload.movements,
            "semantic_movement"
        )

        this.renderSection(
            this.additionsTarget,
            this.payload.additions,
            "added_entity"
        )

        this.renderSection(
            this.removalsTarget,
            this.payload.removals,
            "removed_entity"
        )

        this.renderSection(
            this.warningsTarget,
            this.payload.warnings,
            "identity_warning"
        )

        this.applyFilter()
    }

    renderSummary() {
        const summary =
            this.payload.summary

        this.summaryTarget.innerHTML = `
            <div class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
                <span class="block text-[10px] font-black uppercase tracking-widest text-slate-400">
                    Total
                </span>
                <strong class="mt-1 block text-xl font-black text-slate-800">
                    ${this.escapeHtml(summary.total || 0)}
                </strong>
            </div>

            <div class="rounded-2xl border border-orange-100 bg-orange-50/60 p-4 shadow-sm">
                <span class="block text-[10px] font-black uppercase tracking-widest text-orange-500">
                    Changes
                </span>
                <strong class="mt-1 block text-xl font-black text-orange-700">
                    ${this.escapeHtml(summary.changes || 0)}
                </strong>
            </div>

            <div class="rounded-2xl border border-violet-100 bg-violet-50/60 p-4 shadow-sm">
                <span class="block text-[10px] font-black uppercase tracking-widest text-violet-500">
                    Moved
                </span>
                <strong class="mt-1 block text-xl font-black text-violet-700">
                    ${this.escapeHtml(summary.movements || 0)}
                </strong>
            </div>

            <div class="rounded-2xl border border-emerald-100 bg-emerald-50/60 p-4 shadow-sm">
                <span class="block text-[10px] font-black uppercase tracking-widest text-emerald-500">
                    Added
                </span>
                <strong class="mt-1 block text-xl font-black text-emerald-700">
                    ${this.escapeHtml(summary.additions || 0)}
                </strong>
            </div>

            <div class="rounded-2xl border border-rose-100 bg-rose-50/60 p-4 shadow-sm">
                <span class="block text-[10px] font-black uppercase tracking-widest text-rose-500">
                    Removed
                </span>
                <strong class="mt-1 block text-xl font-black text-rose-700">
                    ${this.escapeHtml(summary.removals || 0)}
                </strong>
            </div>

            <div class="rounded-2xl border border-amber-100 bg-amber-50/60 p-4 shadow-sm">
                <span class="block text-[10px] font-black uppercase tracking-widest text-amber-500">
                    Warnings
                </span>
                <strong class="mt-1 block text-xl font-black text-amber-700">
                    ${this.escapeHtml(summary.warnings || 0)}
                </strong>
            </div>
        `
    }

    renderSection(
        target,
        facts,
        type
    ) {
        if (!target) {
            return
        }

        if (!facts.length) {
            target.innerHTML = `
                <div class="rounded-2xl border border-dashed border-slate-200 bg-slate-50/70 p-8 text-center">
                    <div class="text-2xl">✦</div>

                    <div class="mt-2 text-sm font-black text-slate-600">
                        No ${this.sectionLabel(type).toLowerCase()}.
                    </div>

                    <div class="mt-1 text-xs text-slate-400">
                        This section is currently clean.
                    </div>
                </div>
            `

            return
        }

        target.innerHTML =
            facts
                .map(
                    (fact, index) =>
                        this.renderFact(
                            fact,
                            index
                        )
                )
                .join("")
    }

    renderFact(
        fact,
        index
    ) {
        const type =
            fact.type

        const path =
            this.formatPath(
                fact.path
            )

        const identity =
            fact.identity === null ||
            fact.identity === undefined ||
            fact.identity === ""
                ? ""
                : `
                    <div class="mt-3 text-xs text-slate-400">
                        Identity:
                        <code class="rounded-lg bg-slate-100 px-2 py-1 text-slate-600">
                            ${this.escapeHtml(
                    fact.identity
                )}
                        </code>
                    </div>
                `

        const indexes =
            type === "semantic_movement"
                ? `
                    <div class="mt-3 inline-flex items-center gap-2 rounded-xl bg-violet-50 px-3 py-1.5 text-xs font-black text-violet-700">
                        Position
                        ${this.escapeHtml(
                    String(
                        fact.old_index
                    )
                )}
                        →
                        ${this.escapeHtml(
                    String(
                        fact.new_index
                    )
                )}
                    </div>
                `
                : ""

        const values =
            this.renderValues(
                fact
            )

        const reviewKey =
            this.reviewKey(
                fact,
                index
            )

        return `
            <article
                class="group relative rounded-[24px] border border-slate-200 bg-white p-5 shadow-sm transition-all duration-300 hover:-translate-y-0.5 hover:border-violet-200 hover:shadow-lg hover:shadow-violet-100/50"
                data-comparison-row
                data-change-type="${this.escapeHtml(type)}"
                data-comparison-path="${this.escapeHtml(path)}"
                data-comparison-identity="${this.escapeHtml(fact.identity || "")}"
                data-old-value="${this.escapeHtml(this.formatValue(fact.old_value))}"
                data-new-value="${this.escapeHtml(this.formatValue(fact.new_value))}"
                data-review-key="${this.escapeHtml(reviewKey)}"
                data-reviewed="false"
            >
                <div class="flex flex-col gap-4 xl:flex-row xl:items-start xl:justify-between">

                    <div class="min-w-0 flex-1">

                        <div class="flex flex-wrap items-center gap-2">

                            <span class="inline-flex rounded-full border px-3 py-1 text-[10px] font-black uppercase tracking-wider ${this.badgeClasses(type)}">
                                ${this.escapeHtml(
            this.typeLabel(type)
        )}
                            </span>

                            <span class="max-w-full truncate rounded-lg bg-slate-50 px-2.5 py-1 text-xs font-bold text-slate-500">
                                ${this.escapeHtml(path)}
                            </span>

                        </div>

                        ${identity}

                        ${indexes}

                        ${values}

                    </div>

                    <div class="flex shrink-0 items-center gap-2">

                        <button
                            type="button"
                            data-comparison-review-button
                            data-action="click->entity-comparison-engagement#toggleReviewed"
                            aria-pressed="false"
                            class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-[11px] font-black text-slate-500 shadow-sm transition hover:border-emerald-200 hover:bg-emerald-50 hover:text-emerald-700"
                        >
                            Mark reviewed
                        </button>

                    </div>

                </div>
            </article>
        `
    }

    reviewKey(
        fact,
        index
    ) {
        if (
            fact.identity !== null &&
            fact.identity !== undefined &&
            String(fact.identity).length > 0
        ) {
            return `identity:${fact.identity}`
        }

        const path =
            this.formatPath(
                fact.path
            )

        return [
            fact.type,
            path,
            index
        ].join(":")
    }

    badgeClasses(type) {
        switch (type) {
            case "content_change":
                return "border-orange-200 bg-orange-50 text-orange-700"

            case "semantic_movement":
                return "border-violet-200 bg-violet-50 text-violet-700"

            case "added_entity":
                return "border-emerald-200 bg-emerald-50 text-emerald-700"

            case "removed_entity":
                return "border-rose-200 bg-rose-50 text-rose-700"

            case "identity_warning":
                return "border-amber-200 bg-amber-50 text-amber-700"

            default:
                return "border-slate-200 bg-slate-50 text-slate-600"
        }
    }

    renderValues(fact) {
        if (
            fact.type ===
            "semantic_movement"
        ) {
            return ""
        }

        if (
            fact.type ===
            "identity_warning"
        ) {
            return this.renderWarningMetadata(
                fact.metadata || {}
            )
        }

        return `
            <div class="mt-5 grid gap-3 lg:grid-cols-2">

                <div class="overflow-hidden rounded-2xl border border-rose-100 bg-rose-50/40">
                    <div class="border-b border-rose-100 px-4 py-2 text-[10px] font-black uppercase tracking-widest text-rose-500">
                        Old
                    </div>

                    <pre class="max-h-72 overflow-auto p-4 text-xs leading-6 text-slate-600">${this.escapeHtml(
            this.formatValue(
                fact.old_value
            )
        )}</pre>
                </div>

                <div class="overflow-hidden rounded-2xl border border-emerald-100 bg-emerald-50/40">
                    <div class="border-b border-emerald-100 px-4 py-2 text-[10px] font-black uppercase tracking-widest text-emerald-500">
                        New
                    </div>

                    <pre class="max-h-72 overflow-auto p-4 text-xs leading-6 text-slate-600">${this.escapeHtml(
            this.formatValue(
                fact.new_value
            )
        )}</pre>
                </div>

            </div>
        `
    }

    renderWarningMetadata(
        metadata
    ) {
        const rows =
            Object.entries(
                metadata || {}
            )

        if (!rows.length) {
            return ""
        }

        return `
            <dl class="mt-5 rounded-2xl border border-amber-100 bg-amber-50/50 p-4">
                ${rows
            .map(
                ([key, value]) => `
                            <div class="grid gap-1 border-b border-amber-100 py-3 last:border-0 last:pb-0 first:pt-0 sm:grid-cols-[180px_1fr]">
                                <dt class="text-[10px] font-black uppercase tracking-widest text-amber-500">
                                    ${this.escapeHtml(key)}
                                </dt>

                                <dd class="text-xs leading-5 text-slate-600">
                                    ${this.escapeHtml(
                    this.formatValue(
                        value
                    )
                )}
                                </dd>
                            </div>
                        `
            )
            .join("")}
            </dl>
        `
    }

    filter(event) {
        this.activeFilter =
            event.currentTarget.dataset.filter ||
            "all"

        this.applyFilter()

        this.element
            .querySelectorAll(
                "[data-entity-diff-filter]"
            )
            .forEach(
                (button) => {
                    button.classList.toggle(
                        "is-active",
                        button.dataset.filter ===
                        this.activeFilter
                    )
                }
            )
    }

    applyFilter() {
        const allFacts =
            this.element.querySelectorAll(
                ".entity-diff-fact, [data-comparison-row]"
            )

        let visibleCount = 0

        allFacts.forEach(
            (fact) => {
                const type =
                    fact.dataset.diffType ||
                    fact.dataset.changeType

                const shouldShow =
                    this.activeFilter ===
                    "all" ||
                    this.activeFilter ===
                    type

                fact.hidden =
                    !shouldShow

                if (shouldShow) {
                    visibleCount += 1
                }
            }
        )

        if (this.hasEmptyTarget) {
            this.emptyTarget.hidden =
                visibleCount !== 0
        }
    }

    sectionLabel(type) {
        switch (type) {
            case "content_change":
                return "content changes"

            case "semantic_movement":
                return "movements"

            case "added_entity":
                return "additions"

            case "removed_entity":
                return "removals"

            case "identity_warning":
                return "identity warnings"

            default:
                return "items"
        }
    }

    typeLabel(type) {
        switch (type) {
            case "content_change":
                return "Changed"

            case "semantic_movement":
                return "Moved"

            case "added_entity":
                return "Added"

            case "removed_entity":
                return "Removed"

            case "identity_warning":
                return "Identity warning"

            default:
                return type
        }
    }

    formatPath(path) {
        if (
            !Array.isArray(path) ||
            path.length === 0
        ) {
            return "Root"
        }

        return path
            .map(
                (part) =>
                    String(part)
            )
            .join(" › ")
    }

    formatValue(value) {
        if (
            value === null ||
            value === undefined
        ) {
            return "—"
        }

        if (
            typeof value ===
            "object"
        ) {
            return JSON.stringify(
                value,
                null,
                2
            )
        }

        return String(value)
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