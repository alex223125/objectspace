import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "tree",
        "search",
        "summary",
        "changesOnly",
        "empty"
    ]

    static values = {
        diff: Object
    }

    connect() {
        this.nodes = this.diffValue.nodes || []
        this.summaryData = this.diffValue.summary || {}

        this.render()
    }

    render() {
        this.renderSummary()
        this.renderTree()
    }

    renderSummary() {
        if (!this.hasSummaryTarget) {
            return
        }

        const summary = this.summaryData

        this.summaryTarget.innerHTML = `
      <div class="grid grid-cols-2 gap-3 sm:grid-cols-4 xl:grid-cols-7">

        ${this.metric(
            "Total",
            summary.total || 0,
            "slate"
        )}

        ${this.metric(
            "Changed",
            summary.changed || 0,
            "amber"
        )}

        ${this.metric(
            "Added",
            summary.added || 0,
            "emerald"
        )}

        ${this.metric(
            "Removed",
            summary.removed || 0,
            "rose"
        )}

        ${this.metric(
            "Reordered",
            summary.reordered || 0,
            "violet"
        )}

        ${this.metric(
            "Unchanged",
            summary.unchanged || 0,
            "sky"
        )}

        ${this.metric(
            "Changes",
            summary.changes || 0,
            "orange"
        )}

      </div>
    `
    }

    metric(label, value, color) {
        const colors = {
            slate: "bg-slate-50 border-slate-200 text-slate-700",
            amber: "bg-amber-50 border-amber-200 text-amber-700",
            emerald: "bg-emerald-50 border-emerald-200 text-emerald-700",
            rose: "bg-rose-50 border-rose-200 text-rose-700",
            violet: "bg-violet-50 border-violet-200 text-violet-700",
            sky: "bg-sky-50 border-sky-200 text-sky-700",
            orange: "bg-orange-50 border-orange-200 text-orange-700"
        }

        return `
      <div
        class="
          rounded-2xl
          border
          px-4
          py-3
          ${colors[color]}
        "
      >
        <div class="text-[10px] font-black uppercase tracking-widest opacity-60">
          ${this.escapeHtml(label)}
        </div>

        <div class="mt-1 text-xl font-black">
          ${value}
        </div>
      </div>
    `
    }

    renderTree() {
        if (!this.hasTreeTarget) {
            return
        }

        const query =
            this.hasSearchTarget
                ? this.searchTarget.value.trim().toLowerCase()
                : ""

        const changesOnly =
            this.hasChangesOnlyTarget &&
            this.changesOnlyTarget.checked

        const filtered =
            this.filterNodes(
                this.nodes,
                query,
                changesOnly
            )

        if (filtered.length === 0) {
            this.treeTarget.innerHTML = ""

            if (this.hasEmptyTarget) {
                this.emptyTarget.classList.remove("hidden")
            }

            return
        }

        if (this.hasEmptyTarget) {
            this.emptyTarget.classList.add("hidden")
        }

        this.treeTarget.innerHTML =
            filtered
                .map(node => this.renderNode(node))
                .join("")
    }

    filterNodes(nodes, query, changesOnly) {
        return nodes
            .map(node => this.filterNode(
                node,
                query,
                changesOnly
            ))
            .filter(Boolean)
    }

    filterNode(node, query, changesOnly) {
        const children =
            this.filterNodes(
                node.children || [],
                query,
                changesOnly
            )

        const matchesQuery =
            !query ||
            this.nodeMatchesQuery(node, query)

        const isChange =
            node.change_type !== "unchanged"

        const matchesChangeFilter =
            !changesOnly || isChange

        if (
            matchesQuery &&
            matchesChangeFilter
        ) {
            return {
                ...node,
                children
            }
        }

        if (children.length > 0) {
            return {
                ...node,
                children
            }
        }

        return null
    }

    nodeMatchesQuery(node, query) {
        return [
            node.path,
            node.key,
            node.kind,
            node.change_type,
            node.metadata?.semantic_key
        ]
            .filter(Boolean)
            .join(" ")
            .toLowerCase()
            .includes(query)
    }

    renderNode(node, depth = 0) {
        const change =
            this.changePresentation(
                node.change_type
            )

        const children =
            node.children || []

        const hasChildren =
            children.length > 0

        const identifier =
            `diff-node-${this.slug(node.path)}-${depth}`

        return `
      <div
        class="
          group
          border-b border-slate-100
          last:border-b-0
        "
        data-diff-node
        data-change-type="${this.escapeHtml(node.change_type)}"
      >

        <div
          class="
            flex flex-col gap-3
            px-4 py-4
            transition-colors
            hover:bg-slate-50/70
            lg:flex-row
            lg:items-start
          "
        >

          <div
            class="
              flex
              min-w-0
              flex-1
              items-start
              gap-3
            "
          >

            <div class="mt-0.5">
              ${this.changeIcon(node.change_type)}
            </div>

            <div class="min-w-0 flex-1">

              <div class="flex flex-wrap items-center gap-2">

                <span
                  class="
                    rounded-full
                    border
                    px-2.5 py-1
                    text-[9px]
                    font-black
                    uppercase
                    tracking-widest
                    ${change.badge}
                  "
                >
                  ${this.escapeHtml(change.label)}
                </span>

                <span
                  class="
                    text-[12px]
                    font-black
                    text-slate-700
                    break-all
                  "
                >
                  ${this.escapeHtml(
            node.path || "(root)"
        )}
                </span>

                ${
            node.kind
                ? `
                      <span
                        class="
                          rounded-full
                          bg-slate-100
                          px-2
                          py-0.5
                          text-[9px]
                          font-bold
                          text-slate-500
                        "
                      >
                        ${this.escapeHtml(node.kind)}
                      </span>
                    `
                : ""
        }

              </div>

              ${
            node.metadata?.semantic_key
                ? `
                    <div
                      class="
                        mt-1
                        text-[10px]
                        font-medium
                        text-slate-400
                      "
                    >
                      Semantic key:
                      <span class="font-bold text-slate-500">
                        ${this.escapeHtml(
                    node.metadata.semantic_key
                )}
                      </span>
                    </div>
                  `
                : ""
        }

              ${
            node.old_index !== null &&
            node.old_index !== undefined
                ? `
                    <div
                      class="
                        mt-1
                        text-[10px]
                        text-slate-400
                      "
                    >
                      ${
                    node.new_index !== null &&
                    node.new_index !== undefined
                        ? `
                            Position:
                            <span class="font-bold text-slate-500">
                              ${node.old_index}
                            </span>
                            →
                            <span class="font-bold text-slate-500">
                              ${node.new_index}
                            </span>
                          `
                        : `
                            Previous index:
                            <span class="font-bold text-slate-500">
                              ${node.old_index}
                            </span>
                          `
                }
                    </div>
                  `
                : ""
        }

            </div>

          </div>

          <div
            class="
              flex
              w-full
              min-w-0
              flex-1
              flex-col
              gap-2
              lg:max-w-2xl
              lg:flex-row
            "
          >

            <div
              class="
                min-w-0
                flex-1
                rounded-2xl
                border
                border-rose-100
                bg-rose-50/50
                p-3
              "
            >
              <div
                class="
                  mb-2
                  text-[9px]
                  font-black
                  uppercase
                  tracking-widest
                  text-rose-400
                "
              >
                Previous
              </div>

              <pre
                class="
                  max-h-48
                  overflow-auto
                  whitespace-pre-wrap
                  break-words
                  text-[11px]
                  leading-5
                  text-slate-600
                "
              >${this.escapeHtml(
            this.formatValue(node.old_value)
        )}</pre>
            </div>

            <div
              class="
                hidden
                items-center
                justify-center
                text-slate-300
                lg:flex
              "
            >
              →
            </div>

            <div
              class="
                min-w-0
                flex-1
                rounded-2xl
                border
                border-emerald-100
                bg-emerald-50/50
                p-3
              "
            >
              <div
                class="
                  mb-2
                  text-[9px]
                  font-black
                  uppercase
                  tracking-widest
                  text-emerald-500
                "
              >
                Current
              </div>

              <pre
                class="
                  max-h-48
                  overflow-auto
                  whitespace-pre-wrap
                  break-words
                  text-[11px]
                  leading-5
                  text-slate-600
                "
              >${this.escapeHtml(
            this.formatValue(node.new_value)
        )}</pre>
            </div>

          </div>

        </div>

        ${
            hasChildren
                ? `
              <div
                class="
                  ml-4
                  border-l
                  border-slate-100
                  pl-2
                "
              >
                ${children
                    .map(child =>
                        this.renderNode(
                            child,
                            depth + 1
                        )
                    )
                    .join("")}
              </div>
            `
                : ""
        }

      </div>
    `
    }

    changePresentation(type) {
        switch (type) {
            case "added":
                return {
                    label: "Added",
                    badge:
                        "border-emerald-200 bg-emerald-50 text-emerald-700"
                }

            case "removed":
                return {
                    label: "Removed",
                    badge:
                        "border-rose-200 bg-rose-50 text-rose-700"
                }

            case "changed":
                return {
                    label: "Changed",
                    badge:
                        "border-amber-200 bg-amber-50 text-amber-700"
                }

            case "reordered":
                return {
                    label: "Reordered",
                    badge:
                        "border-violet-200 bg-violet-50 text-violet-700"
                }

            default:
                return {
                    label: "Unchanged",
                    badge:
                        "border-slate-200 bg-slate-50 text-slate-500"
                }
        }
    }

    changeIcon(type) {
        switch (type) {
            case "added":
                return `
          <span
            class="
              flex h-7 w-7
              items-center justify-center
              rounded-xl
              bg-emerald-100
              text-emerald-600
              font-black
            "
          >
            +
          </span>
        `

            case "removed":
                return `
          <span
            class="
              flex h-7 w-7
              items-center justify-center
              rounded-xl
              bg-rose-100
              text-rose-600
              font-black
            "
          >
            −
          </span>
        `

            case "changed":
                return `
          <span
            class="
              flex h-7 w-7
              items-center justify-center
              rounded-xl
              bg-amber-100
              text-amber-600
              font-black
            "
          >
            ≠
          </span>
        `

            case "reordered":
                return `
          <span
            class="
              flex h-7 w-7
              items-center justify-center
              rounded-xl
              bg-violet-100
              text-violet-600
              font-black
            "
          >
            ↕
          </span>
        `

            default:
                return `
          <span
            class="
              flex h-7 w-7
              items-center justify-center
              rounded-xl
              bg-slate-100
              text-slate-400
              font-black
            "
          >
            =
          </span>
        `
        }
    }

    search() {
        this.renderTree()
    }

    toggleChangesOnly() {
        this.renderTree()
    }

    clearSearch() {
        if (this.hasSearchTarget) {
            this.searchTarget.value = ""
        }

        this.renderTree()
    }

    formatValue(value) {
        if (value === null) {
            return "null"
        }

        if (value === undefined) {
            return "undefined"
        }

        if (typeof value === "string") {
            return value
        }

        try {
            return JSON.stringify(
                value,
                null,
                2
            )
        } catch (_error) {
            return String(value)
        }
    }

    slug(value) {
        return String(value || "root")
            .replace(/[^a-zA-Z0-9_-]/g, "-")
            .slice(0, 80)
    }

    escapeHtml(value) {
        return String(value ?? "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;")
    }
}