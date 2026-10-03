import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "summary",
        "tree",
        "empty",
        "search",
        "changesOnly",
        "counter",
        "filterButton"
    ]

    static values = {
        diff: Object
    }

    connect() {
        this.currentFilter = "all"
        this.expanded = new Set()

        this.render()
    }

    // ==========================================================
    // RENDER
    // ==========================================================

    render() {
        this.renderSummary()
        this.renderTree()
    }

    // ==========================================================
    // SUMMARY
    // ==========================================================

    renderSummary() {
        if (!this.hasSummaryTarget) return

        const summary =
            this.diffValue?.summary || {}

        const cards = [
            {
                label: "Total",
                value: summary.total || 0,
                color: "slate"
            },
            {
                label: "Changed",
                value: summary.changed || 0,
                color: "amber"
            },
            {
                label: "Added",
                value: summary.added || 0,
                color: "emerald"
            },
            {
                label: "Removed",
                value: summary.removed || 0,
                color: "rose"
            },
            {
                label: "Moved",
                value: summary.moved || 0,
                color: "violet"
            },
            {
                label: "Unchanged",
                value: summary.unchanged || 0,
                color: "slate"
            }
        ]

        this.summaryTarget.innerHTML = `
      <div class="grid grid-cols-2 gap-3 md:grid-cols-3 xl:grid-cols-6">
        ${cards.map(card => `
          <button
            type="button"
            class="
              rounded-2xl
              border-2
              border-${card.color}-100
              bg-${card.color}-50
              p-4
              text-left
              transition
              hover:-translate-y-0.5
              hover:shadow-sm
            "
            data-filter="${card.label.toLowerCase()}"
            data-action="click->entity-version-diff#summaryFilter"
          >
            <div class="
              text-[9px]
              font-black
              uppercase
              tracking-widest
              text-${card.color}-500
            ">
              ${card.label}
            </div>

            <div class="
              mt-2
              text-2xl
              font-black
              text-slate-800
            ">
              ${card.value}
            </div>
          </button>
        `).join("")}
      </div>

      <div class="
        mt-4
        flex
        flex-wrap
        gap-2
        text-[10px]
        font-bold
        text-slate-400
      ">
        <span>
          ${summary.changed_percentage || 0}% changed
        </span>

        <span>·</span>

        <span>
          ${summary.added_percentage || 0}% added
        </span>

        <span>·</span>

        <span>
          ${summary.removed_percentage || 0}% removed
        </span>

        <span>·</span>

        <span>
          ${summary.moved_percentage || 0}% moved
        </span>
      </div>
    `
    }

    // ==========================================================
    // TREE
    // ==========================================================

    renderTree() {
        if (!this.hasTreeTarget) return

        const nodes =
            this.diffValue?.nodes || []

        const visibleNodes =
            this.filteredNodes(nodes)

        if (visibleNodes.length === 0) {
            this.treeTarget.innerHTML = ""

            if (this.hasEmptyTarget) {
                this.emptyTarget.classList.remove("hidden")
            }

            this.updateCounter(0)

            return
        }

        if (this.hasEmptyTarget) {
            this.emptyTarget.classList.add("hidden")
        }

        this.treeTarget.innerHTML =
            visibleNodes
                .map((node, index) =>
                    this.renderNode(node, index)
                )
                .join("")

        this.updateCounter(
            visibleNodes.length
        )
    }

    // ==========================================================
    // NODE
    // ==========================================================

    renderNode(node, index) {
        const type =
            node.change_type || "unchanged"

        const path =
            node.path || "root"

        const depth =
            Number(node.depth || 0)

        const identity =
            node.metadata?.identity

        const oldIndex =
            node.metadata?.old_index

        const newIndex =
            node.metadata?.new_index

        const id =
            `entity-diff-${index}-${this.slug(path)}`

        const changed =
            type !== "unchanged"

        const typeStyles =
            this.typeStyles(type)

        const inlineOld =
            this.renderInlineValue(
                node.old_value,
                node.inline_diff?.old,
                "old"
            )

        const inlineNew =
            this.renderInlineValue(
                node.new_value,
                node.inline_diff?.new,
                "new"
            )

        return `
      <div
        class="
          border-b
          border-slate-100
          last:border-b-0
          ${changed ? typeStyles.background : "bg-white"}
        "
        data-change-type="${this.escape(type)}"
        data-path="${this.escape(path)}"
      >

        <div
          class="
            flex
            items-start
            gap-3
            px-4
            py-4
            md:px-6
          "
          style="padding-left: ${Math.min(
            24 + depth * 24,
            180
        )}px"
        >

          <div class="
            mt-1
            h-2
            w-2
            shrink-0
            rounded-full
            ${typeStyles.dot}
          "></div>

          <div class="min-w-0 flex-1">

            <div class="
              flex
              flex-wrap
              items-center
              gap-2
            ">

              <button
                type="button"
                class="
                  break-all
                  text-left
                  text-xs
                  font-black
                  text-slate-700
                  hover:text-orange-600
                "
                data-action="click->entity-version-diff#toggleNode"
                data-node-id="${this.escape(id)}"
              >
                ${this.escape(path)}
              </button>

              <span class="
                rounded-full
                px-2
                py-0.5
                text-[8px]
                font-black
                uppercase
                tracking-widest
                ${typeStyles.badge}
              ">
                ${this.escape(type)}
              </span>

              ${
            identity !== undefined
                ? `
                    <span class="
                      rounded-full
                      bg-violet-50
                      px-2
                      py-0.5
                      text-[8px]
                      font-black
                      text-violet-600
                    ">
                      identity: ${this.escape(String(identity))}
                    </span>
                  `
                : ""
        }

              ${
            type === "moved"
                ? `
                    <span class="
                      rounded-full
                      bg-violet-100
                      px-2
                      py-0.5
                      text-[8px]
                      font-black
                      text-violet-700
                    ">
                      ${this.escape(String(oldIndex))}
                      →
                      ${this.escape(String(newIndex))}
                    </span>
                  `
                : ""
        }

            </div>

            <div class="
              mt-3
              grid
              grid-cols-1
              gap-3
              lg:grid-cols-2
            ">

              ${this.renderValuePanel(
            "OLD",
            node.old_value,
            inlineOld,
            "rose"
        )}

              ${this.renderValuePanel(
            "NEW",
            node.new_value,
            inlineNew,
            "emerald"
        )}

            </div>

          </div>

        </div>

      </div>
    `
    }

    // ==========================================================
    // VALUE PANEL
    // ==========================================================

    renderValuePanel(
        label,
        value,
        inlineValue,
        color
    ) {
        const json =
            this.stringify(value)

        const isObject =
            value !== null &&
            typeof value === "object"

        return `
      <div class="
        min-w-0
        overflow-hidden
        rounded-2xl
        border
        border-${color}-100
        bg-white/80
      ">

        <div class="
          flex
          items-center
          justify-between
          border-b
          border-${color}-100
          bg-${color}-50/60
          px-3
          py-2
        ">

          <span class="
            text-[8px]
            font-black
            uppercase
            tracking-widest
            text-${color}-500
          ">
            ${label}
          </span>

          <button
            type="button"
            class="
              rounded-lg
              px-2
              py-1
              text-[8px]
              font-black
              text-slate-400
              hover:bg-white
              hover:text-slate-700
            "
            data-copy-value="${this.escape(json || "")}"
            data-action="click->entity-version-diff#copy"
          >
            Copy
          </button>

        </div>

        <div class="
          max-h-72
          overflow-auto
          whitespace-pre-wrap
          break-words
          p-3
          font-mono
          text-[11px]
          leading-5
          text-slate-600
        ">
          ${
            inlineValue ||
            (
                isObject
                    ? this.highlightJson(json)
                    : this.escape(
                        value === null ||
                        value === undefined
                            ? "—"
                            : String(value)
                    )
            )
        }
        </div>

      </div>
    `
    }

    // ==========================================================
    // INLINE VALUE
    // ==========================================================

    renderInlineValue(
        value,
        tokens,
        side
    ) {
        if (
            !tokens ||
            !Array.isArray(tokens) ||
            tokens.length === 0
        ) {
            return null
        }

        return tokens
            .map(token => {
                const text =
                    this.escape(
                        token.text
                    )

                if (!token.changed) {
                    return text
                }

                const classes =
                    side === "old"
                        ? "bg-rose-200 text-rose-900"
                        : "bg-emerald-200 text-emerald-900"

                return `
          <mark class="
            rounded
            px-0.5
            ${classes}
          ">
            ${text}
          </mark>
        `
            })
            .join("")
    }

    // ==========================================================
    // JSON HIGHLIGHTING
    // ==========================================================

    highlightJson(json) {
        if (!json) {
            return "—"
        }

        const escaped =
            this.escape(json)

        return escaped
            .replace(
                /(&quot;.*?&quot;)(?=\s*:)/g,
                '<span class="text-sky-600 font-bold">$1</span>'
            )
            .replace(
                /(&quot;.*?&quot;)/g,
                '<span class="text-emerald-600">$1</span>'
            )
            .replace(
                /\b(true|false)\b/g,
                '<span class="text-violet-600 font-bold">$1</span>'
            )
            .replace(
                /\b(null)\b/g,
                '<span class="text-slate-400 font-bold">$1</span>'
            )
    }

    // ==========================================================
    // FILTERING
    // ==========================================================

    filteredNodes(nodes) {
        const query =
            this.hasSearchTarget
                ? this.searchTarget.value
                    .trim()
                    .toLowerCase()
                : ""

        const changesOnly =
            this.hasChangesOnlyTarget &&
            this.changesOnlyTarget.checked

        return nodes.filter(node => {
            const type =
                node.change_type || "unchanged"

            if (
                changesOnly &&
                type === "unchanged"
            ) {
                return false
            }

            if (
                this.currentFilter !== "all" &&
                type !== this.currentFilter
            ) {
                return false
            }

            if (!query) {
                return true
            }

            const searchable =
                [
                    node.path,
                    node.old_display,
                    node.new_display,
                    node.metadata?.identity
                ]
                    .filter(value => value !== undefined)
                    .join(" ")
                    .toLowerCase()

            return searchable.includes(query)
        })
    }

    // ==========================================================
    // SEARCH
    // ==========================================================

    search() {
        this.renderTree()
    }

    // ==========================================================
    // CHANGES ONLY
    // ==========================================================

    toggleChangesOnly() {
        this.renderTree()
    }

    // ==========================================================
    // FILTER
    // ==========================================================

    filter(event) {
        event.preventDefault()

        this.currentFilter =
            event.currentTarget.dataset.filter ||
            "all"

        this.renderTree()
    }

    summaryFilter(event) {
        const filter =
            event.currentTarget.dataset.filter

        if (filter === "total") {
            this.currentFilter = "all"
        } else {
            this.currentFilter = filter
        }

        this.renderTree()
    }

    // ==========================================================
    // EXPAND/COLLAPSE
    // ==========================================================

    toggleNode(event) {
        const id =
            event.currentTarget.dataset.nodeId

        if (!id) return

        if (this.expanded.has(id)) {
            this.expanded.delete(id)
        } else {
            this.expanded.add(id)
        }

        this.renderTree()
    }

    expandAll() {
        const nodes =
            this.diffValue?.nodes || []

        nodes.forEach((node, index) => {
            this.expanded.add(
                `entity-diff-${index}-${this.slug(node.path)}`
            )
        })

        this.renderTree()
    }

    collapseAll() {
        this.expanded.clear()

        this.renderTree()
    }

    // ==========================================================
    // COPY
    // ==========================================================

    async copy(event) {
        event.preventDefault()

        const value =
            event.currentTarget.dataset.copyValue || ""

        try {
            await navigator.clipboard.writeText(value)

            const button =
                event.currentTarget

            const original =
                button.textContent

            button.textContent =
                "Copied"

            setTimeout(() => {
                button.textContent =
                    original
            }, 1000)

        } catch (_) {
            // Clipboard unavailable.
        }
    }

    // ==========================================================
    // COUNTER
    // ==========================================================

    updateCounter(value) {
        if (!this.hasCounterTarget) return

        this.counterTarget.textContent =
            `${value} visible`
    }

    // ==========================================================
    // STYLES
    // ==========================================================

    typeStyles(type) {
        switch (type) {
            case "added":
                return {
                    background: "bg-emerald-50/40",
                    dot: "bg-emerald-400",
                    badge:
                        "bg-emerald-100 text-emerald-700"
                }

            case "removed":
                return {
                    background: "bg-rose-50/40",
                    dot: "bg-rose-400",
                    badge:
                        "bg-rose-100 text-rose-700"
                }

            case "changed":
                return {
                    background: "bg-amber-50/40",
                    dot: "bg-amber-400",
                    badge:
                        "bg-amber-100 text-amber-700"
                }

            case "moved":
                return {
                    background: "bg-violet-50/40",
                    dot: "bg-violet-400",
                    badge:
                        "bg-violet-100 text-violet-700"
                }

            default:
                return {
                    background: "bg-white",
                    dot: "bg-slate-300",
                    badge:
                        "bg-slate-100 text-slate-500"
                }
        }
    }

    // ==========================================================
    // HELPERS
    // ==========================================================

    stringify(value) {
        if (value === null || value === undefined) {
            return ""
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
        } catch (_) {
            return String(value)
        }
    }

    slug(value) {
        return String(value || "root")
            .replace(/[^a-zA-Z0-9_-]+/g, "-")
            .replace(/^-+|-+$/g, "")
            .slice(0, 80)
    }

    escape(value) {
        return String(value ?? "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;")
    }
}