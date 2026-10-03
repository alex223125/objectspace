import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "row",
    "search",
    "typeFilter",
    "visibleCount",
    "empty",
    "reset"
  ]

  connect() {
    this.activeFilter = "all"
    this.searchTerm = ""
    this.exploredTypes = new Set()
    this.keyboardHandler = this.handleKeyboard.bind(this)

    this.buildPremiumCockpit()
    this.applyFilters()

    document.addEventListener(
        "keydown",
        this.keyboardHandler
    )
  }

  disconnect() {
    document.removeEventListener(
        "keydown",
        this.keyboardHandler
    )

    this.cockpit?.remove()
  }

  // ============================================================
  // PREMIUM COCKPIT
  // ============================================================

  buildPremiumCockpit() {
    if (
        this.element.querySelector(
            "[data-comparison-cockpit]"
        )
    ) {
      return
    }

    this.cockpit =
        document.createElement("section")

    this.cockpit.dataset.comparisonCockpit =
        "true"

    this.cockpit.className = `
            mb-8
            overflow-hidden
            rounded-[32px]
            border-2 border-orange-100
            bg-gradient-to-br
            from-white
            via-orange-50/30
            to-slate-50
            shadow-xl
            shadow-orange-100/30
        `

    this.cockpit.innerHTML =
        this.cockpitMarkup()

    this.element.prepend(
        this.cockpit
    )

    this.bindCockpitActions()
    this.updateCockpit()
  }

  cockpitMarkup() {
    return `
            <div class="relative overflow-hidden">

                <div
                    class="
                        pointer-events-none
                        absolute
                        -right-24
                        -top-24
                        h-72
                        w-72
                        rounded-full
                        bg-orange-200/20
                        blur-3xl
                    "
                ></div>

                <div
                    class="
                        pointer-events-none
                        absolute
                        -bottom-32
                        left-1/3
                        h-64
                        w-64
                        rounded-full
                        bg-violet-200/20
                        blur-3xl
                    "
                ></div>

                <div class="relative p-6 md:p-8">

                    <div
                        class="
                            flex
                            flex-col
                            gap-6
                            lg:flex-row
                            lg:items-start
                            lg:justify-between
                        "
                    >

                        <div class="min-w-0">

                            <div
                                class="
                                    mb-3
                                    flex
                                    flex-wrap
                                    items-center
                                    gap-2
                                "
                            >

                                <span
                                    class="
                                        inline-flex
                                        items-center
                                        gap-2
                                        rounded-full
                                        border
                                        border-orange-200
                                        bg-orange-50
                                        px-3
                                        py-1.5
                                        text-[10px]
                                        font-black
                                        uppercase
                                        tracking-[0.18em]
                                        text-orange-700
                                    "
                                >
                                    <span
                                        class="
                                            h-2
                                            w-2
                                            rounded-full
                                            bg-emerald-400
                                            shadow-[0_0_8px_rgba(52,211,153,0.8)]
                                        "
                                    ></span>

                                    Comparison Intelligence
                                </span>

                                <span
                                    data-comparison-cockpit-status
                                    class="
                                        rounded-full
                                        border
                                        border-slate-200
                                        bg-white/80
                                        px-3
                                        py-1.5
                                        text-[10px]
                                        font-black
                                        uppercase
                                        tracking-wider
                                        text-slate-500
                                    "
                                >
                                    Ready
                                </span>

                            </div>

                            <h2
                                class="
                                    text-2xl
                                    font-black
                                    tracking-tight
                                    text-slate-800
                                    md:text-3xl
                                "
                            >
                                Explore the evolution
                            </h2>

                            <p
                                class="
                                    mt-2
                                    max-w-2xl
                                    text-sm
                                    leading-6
                                    text-slate-500
                                "
                            >
                                Investigate what changed, what moved,
                                what appeared, what disappeared and
                                where identity requires attention.
                            </p>

                        </div>

                        <div
                            class="
                                flex
                                shrink-0
                                items-center
                                gap-3
                                rounded-2xl
                                border
                                border-orange-100
                                bg-white/80
                                px-4
                                py-3
                                shadow-sm
                            "
                        >

                            <div
                                class="
                                    flex
                                    h-11
                                    w-11
                                    items-center
                                    justify-center
                                    rounded-2xl
                                    bg-gradient-to-br
                                    from-orange-400
                                    to-amber-400
                                    text-lg
                                    shadow-md
                                    shadow-orange-200/60
                                "
                            >
                                ✦
                            </div>

                            <div>

                                <div
                                    class="
                                        text-[9px]
                                        font-black
                                        uppercase
                                        tracking-[0.16em]
                                        text-slate-400
                                    "
                                >
                                    Discovery score
                                </div>

                                <div
                                    data-comparison-discovery-score
                                    class="
                                        mt-0.5
                                        text-xl
                                        font-black
                                        text-slate-800
                                    "
                                >
                                    0%
                                </div>

                            </div>

                        </div>

                    </div>


                    <!-- METRICS -->

                    <div
                        class="
                            mt-7
                            grid
                            grid-cols-2
                            gap-3
                            md:grid-cols-5
                        "
                    >

                        ${this.metricCard(
        "total",
        "Total",
        "bg-slate-50",
        "text-slate-700"
    )}

                        ${this.metricCard(
        "changes",
        "Changed",
        "bg-orange-50",
        "text-orange-700"
    )}

                        ${this.metricCard(
        "moved",
        "Moved",
        "bg-violet-50",
        "text-violet-700"
    )}

                        ${this.metricCard(
        "added",
        "Added",
        "bg-emerald-50",
        "text-emerald-700"
    )}

                        ${this.metricCard(
        "removed",
        "Removed",
        "bg-rose-50",
        "text-rose-700"
    )}

                    </div>


                    <!-- DISCOVERY PROGRESS -->

                    <div
                        class="
                            mt-6
                            rounded-2xl
                            border
                            border-orange-100
                            bg-white/80
                            p-4
                        "
                    >

                        <div
                            class="
                                mb-2
                                flex
                                items-center
                                justify-between
                                gap-4
                            "
                        >

                            <div
                                class="
                                    flex
                                    items-center
                                    gap-2
                                "
                            >

                                <span
                                    class="
                                        text-sm
                                    "
                                >
                                    🧭
                                </span>

                                <span
                                    class="
                                        text-[10px]
                                        font-black
                                        uppercase
                                        tracking-[0.15em]
                                        text-slate-500
                                    "
                                >
                                    Discovery progress
                                </span>

                            </div>

                            <span
                                data-comparison-discovery-label
                                class="
                                    text-[10px]
                                    font-black
                                    text-orange-500
                                "
                            >
                                Start exploring
                            </span>

                        </div>

                        <div
                            class="
                                h-2.5
                                overflow-hidden
                                rounded-full
                                bg-slate-100
                            "
                        >

                            <div
                                data-comparison-discovery-bar
                                class="
                                    h-full
                                    w-0
                                    rounded-full
                                    bg-gradient-to-r
                                    from-orange-400
                                    via-amber-400
                                    via-violet-400
                                    to-emerald-400
                                    shadow-sm
                                    transition-all
                                    duration-700
                                "
                            ></div>

                        </div>

                    </div>


                    <!-- ACTIVE FILTER -->

                    <div
                        data-comparison-active-filter
                        class="
                            mt-4
                            hidden
                            items-center
                            justify-between
                            gap-3
                            rounded-2xl
                            border
                            border-sky-100
                            bg-sky-50/70
                            px-4
                            py-3
                        "
                    >

                        <div
                            class="
                                flex
                                items-center
                                gap-2
                            "
                        >

                            <span>🔎</span>

                            <span
                                class="
                                    text-xs
                                    font-bold
                                    text-sky-700
                                "
                            >
                                Active exploration filter
                            </span>

                            <span
                                data-comparison-active-filter-label
                                class="
                                    rounded-full
                                    bg-white
                                    px-2.5
                                    py-1
                                    text-[10px]
                                    font-black
                                    uppercase
                                    tracking-wider
                                    text-sky-600
                                "
                            ></span>

                        </div>

                        <button
                            type="button"
                            data-comparison-cockpit-clear
                            class="
                                rounded-xl
                                px-3
                                py-1.5
                                text-[10px]
                                font-black
                                text-sky-600
                                transition
                                hover:bg-white
                            "
                        >
                            Clear
                        </button>

                    </div>


                    <!-- SHORTCUTS -->

                    <div
                        class="
                            mt-5
                            flex
                            flex-wrap
                            items-center
                            gap-2
                            text-[9px]
                            font-bold
                            text-slate-400
                        "
                    >

                        <span
                            class="
                                mr-1
                                uppercase
                                tracking-widest
                            "
                        >
                            Shortcuts
                        </span>

                        ${this.shortcutKey("/", "Search")}

                        ${this.shortcutKey("R", "Reset")}

                        ${this.shortcutKey("1", "All")}

                        ${this.shortcutKey("2", "Changed")}

                        ${this.shortcutKey("3", "Moved")}

                        ${this.shortcutKey("4", "Added")}

                        ${this.shortcutKey("5", "Removed")}

                    </div>

                </div>
            </div>
        `
  }

  metricCard(
      key,
      label,
      background,
      textColor
  ) {
    return `
            <div
                data-comparison-metric="${key}"
                class="
                    rounded-2xl
                    border
                    border-slate-100
                    ${background}
                    p-4
                    transition-all
                    duration-300
                    hover:-translate-y-0.5
                "
            >

                <div
                    class="
                        text-[9px]
                        font-black
                        uppercase
                        tracking-[0.15em]
                        text-slate-400
                    "
                >
                    ${label}
                </div>

                <div
                    data-comparison-metric-value="${key}"
                    class="
                        mt-1
                        text-2xl
                        font-black
                        ${textColor}
                    "
                >
                    0
                </div>

            </div>
        `
  }

  shortcutKey(
      key,
      label
  ) {
    return `
            <span
                class="
                    inline-flex
                    items-center
                    gap-1.5
                    rounded-lg
                    border
                    border-slate-200
                    bg-white
                    px-2
                    py-1
                "
            >
                <kbd
                    class="
                        rounded
                        bg-slate-100
                        px-1.5
                        py-0.5
                        font-black
                        text-slate-600
                    "
                >
                    ${key}
                </kbd>

                ${label}
            </span>
        `
  }

  bindCockpitActions() {
    const clearButton =
        this.cockpit.querySelector(
            "[data-comparison-cockpit-clear]"
        )

    clearButton?.addEventListener(
        "click",
        () => {
          this.resetFilters()
        }
    )
  }

  // ============================================================
  // FILTERING
  // ============================================================

  searchChanged() {
    this.applyFilters()
  }

  typeFilterChanged() {
    this.applyFilters()
  }

  applyFilters() {
    const search =
        this.hasSearchTarget
            ? this.searchTarget.value
                .trim()
                .toLowerCase()
            : ""

    const type =
        this.hasTypeFilterTarget
            ? this.typeFilterTarget.value || "all"
            : "all"

    this.searchTerm = search
    this.activeFilter = type

    let visibleCount = 0

    this.rowTargets.forEach((row) => {
      const rowSearchText =
          [
            row.dataset.comparisonPath,
            row.dataset.comparisonIdentity,
            row.dataset.oldValue,
            row.dataset.newValue,
            row.textContent
          ]
              .filter(
                  (value) =>
                      value !== undefined &&
                      value !== null
              )
              .join(" ")
              .toLowerCase()

      const rowType =
          row.dataset.changeType || ""

      const matchesSearch =
          !search ||
          rowSearchText.includes(search)

      const matchesType =
          type === "all" ||
          rowType === type

      const visible =
          matchesSearch &&
          matchesType

      row.hidden = !visible

      row.setAttribute(
          "aria-hidden",
          visible
              ? "false"
              : "true"
      )

      if (visible) {
        visibleCount += 1
      }
    })

    if (this.hasVisibleCountTarget) {
      this.visibleCountTarget.textContent =
          String(visibleCount)
    }

    if (this.hasEmptyTarget) {
      this.emptyTarget.hidden =
          visibleCount !== 0
    }

    if (type !== "all") {
      this.exploredTypes.add(type)
    }

    this.updateCockpit()
  }

  resetFilters() {
    if (this.hasSearchTarget) {
      this.searchTarget.value = ""
    }

    if (this.hasTypeFilterTarget) {
      this.typeFilterTarget.value = "all"
    }

    this.applyFilters()
  }

  // ============================================================
  // COCKPIT STATE
  // ============================================================

  updateCockpit() {
    if (!this.cockpit) {
      return
    }

    const total =
        this.rowTargets.length

    const changed =
        this.countType(
            "content_change"
        )

    const moved =
        this.countType(
            "semantic_movement"
        )

    const added =
        this.countType(
            "added_entity"
        )

    const removed =
        this.countType(
            "removed_entity"
        )

    this.setMetric(
        "total",
        total
    )

    this.setMetric(
        "changes",
        changed
    )

    this.setMetric(
        "moved",
        moved
    )

    this.setMetric(
        "added",
        added
    )

    this.setMetric(
        "removed",
        removed
    )

    const score =
        this.discoveryScore()

    const scoreElement =
        this.cockpit.querySelector(
            "[data-comparison-discovery-score]"
        )

    if (scoreElement) {
      scoreElement.textContent =
          `${score}%`
    }

    const bar =
        this.cockpit.querySelector(
            "[data-comparison-discovery-bar]"
        )

    if (bar) {
      bar.style.width =
          `${score}%`
    }

    const label =
        this.cockpit.querySelector(
            "[data-comparison-discovery-label]"
        )

    if (label) {
      label.textContent =
          this.discoveryLabel(score)
    }

    const status =
        this.cockpit.querySelector(
            "[data-comparison-cockpit-status]"
        )

    if (status) {
      status.textContent =
          total === 0
              ? "No changes"
              : `${total} insights`
    }

    this.updateActiveFilter()
  }

  countType(type) {
    return this.rowTargets.filter(
        (row) =>
            row.dataset.changeType === type
    ).length
  }

  setMetric(
      key,
      value
  ) {
    const element =
        this.cockpit.querySelector(
            `[data-comparison-metric-value="${key}"]`
        )

    if (element) {
      element.textContent =
          String(value)
    }
  }

  discoveryScore() {
    const availableTypes =
        new Set(
            this.rowTargets
                .map(
                    (row) =>
                        row.dataset.changeType
                )
                .filter(Boolean)
        )

    const totalTypes =
        Math.max(
            availableTypes.size,
            1
        )

    const explored =
        this.exploredTypes.size

    const searchBonus =
        this.searchTerm
            ? 20
            : 0

    const filterProgress =
        Math.min(
            80,
            Math.round(
                (explored /
                    totalTypes) *
                80
            )
        )

    return Math.min(
        100,
        filterProgress +
        searchBonus
    )
  }

  discoveryLabel(score) {
    if (score === 0) {
      return "Start exploring"
    }

    if (score < 25) {
      return "First signal discovered"
    }

    if (score < 50) {
      return "Building your map"
    }

    if (score < 75) {
      return "Strong exploration"
    }

    if (score < 100) {
      return "Deep investigation"
    }

    return "Comparison mastered"
  }

  updateActiveFilter() {
    const container =
        this.cockpit.querySelector(
            "[data-comparison-active-filter]"
        )

    const label =
        this.cockpit.querySelector(
            "[data-comparison-active-filter-label]"
        )

    if (!container || !label) {
      return
    }

    const typeLabel =
        this.typeLabel(
            this.activeFilter
        )

    const hasFilter =
        this.activeFilter !== "all" ||
        Boolean(this.searchTerm)

    if (!hasFilter) {
      container.classList.add(
          "hidden"
      )

      container.classList.remove(
          "flex"
      )

      return
    }

    const parts = []

    if (this.activeFilter !== "all") {
      parts.push(typeLabel)
    }

    if (this.searchTerm) {
      parts.push(
          `"${this.searchTerm}"`
      )
    }

    label.textContent =
        parts.join(" · ")

    container.classList.remove(
        "hidden"
    )

    container.classList.add(
        "flex"
    )
  }

  typeLabel(type) {
    const labels = {
      all: "All",
      content_change: "Changed",
      semantic_movement: "Moved",
      added_entity: "Added",
      removed_entity: "Removed",
      identity_warning: "Warnings"
    }

    return (
        labels[type] ||
        type
    )
  }

  // ============================================================
  // KEYBOARD NAVIGATION
  // ============================================================

  handleKeyboard(event) {
    const target =
        event.target

    const isTyping =
        target instanceof
        HTMLInputElement ||
        target instanceof
        HTMLTextAreaElement ||
        target instanceof
        HTMLSelectElement

    if (
        event.key === "/" &&
        !isTyping
    ) {
      event.preventDefault()

      this.searchTarget?.focus()

      return
    }

    if (
        event.key.toLowerCase() === "r" &&
        !isTyping
    ) {
      event.preventDefault()

      this.resetFilters()

      return
    }

    if (
        isTyping
    ) {
      return
    }

    const shortcuts = {
      "1": "all",
      "2": "content_change",
      "3": "semantic_movement",
      "4": "added_entity",
      "5": "removed_entity"
    }

    const selected =
        shortcuts[event.key]

    if (!selected) {
      return
    }

    if (this.hasTypeFilterTarget) {
      this.typeFilterTarget.value =
          selected
    }

    this.applyFilters()
  }
}