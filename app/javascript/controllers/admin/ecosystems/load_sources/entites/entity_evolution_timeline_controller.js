import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "timeline",
        "node",
        "version",
        "date",
        "changes",
        "bar",
        "summary",
        "previous",
        "next"
    ]

    static values = {
        versions: Array
    }

    connect() {
        this.currentIndex = this.findCurrentIndex()

        this.render()

        this.refreshHandler = event => {
            if (event.detail?.versions) {
                this.versionsValue = event.detail.versions
                this.currentIndex = this.findCurrentIndex()
                this.render()
            }
        }

        window.addEventListener(
            "entity-evolution:updated",
            this.refreshHandler
        )
    }

    disconnect() {
        window.removeEventListener(
            "entity-evolution:updated",
            this.refreshHandler
        )
    }

    findCurrentIndex() {
        if (!Array.isArray(this.versionsValue)) {
            return 0
        }

        const index = this.versionsValue.findIndex(
            version =>
                version.current === true ||
                version.is_current === true
        )

        return index >= 0 ? index : this.versionsValue.length - 1
    }

    render() {
        if (!this.hasTimelineTarget) return

        const versions = this.normalizedVersions()

        if (versions.length === 0) {
            this.renderEmpty()
            return
        }

        this.timelineTarget.innerHTML = ""

        const maximumChanges = Math.max(
            ...versions.map(version => version.changes),
            1
        )

        versions.forEach((version, index) => {
            const node = this.buildNode(
                version,
                index,
                maximumChanges
            )

            this.timelineTarget.appendChild(node)
        })

        this.updateNavigation()
        this.updateSummary(versions[this.currentIndex])
    }

    normalizedVersions() {
        return (this.versionsValue || [])
            .map((version, index) => ({
                id: version.id ?? index,
                version:
                    version.version ||
                    version.number ||
                    `Version ${index + 1}`,
                date:
                    version.date ||
                    version.created_at ||
                    version.createdAt ||
                    "",
                changes: Number(
                    version.changes ??
                    version.change_count ??
                    version.changeCount ??
                    0
                ),
                label:
                    version.label ||
                    version.name ||
                    "",
                current:
                    version.current === true ||
                    version.is_current === true,
                milestone:
                    version.milestone === true,
                milestoneLabel:
                    version.milestone_label ||
                    version.milestoneLabel ||
                    ""
            }))
    }

    buildNode(version, index, maximumChanges) {
        const wrapper = document.createElement("div")

        const isCurrent =
            index === this.currentIndex

        const percentage =
            Math.round(
                (version.changes / maximumChanges) * 100
            )

        wrapper.className = `
      relative
      flex
      min-w-[190px]
      flex-1
      flex-col
      items-center
      px-3
      pb-6
    `

        wrapper.dataset.timelineIndex = index

        wrapper.innerHTML = `
      <button
        type="button"
        class="
          group
          relative
          z-10
          flex
          h-11
          w-11
          items-center
          justify-center
          rounded-full
          border-4
          transition-all
          duration-300
          ${
            isCurrent
                ? "border-violet-300 bg-violet-600 text-white shadow-lg shadow-violet-200"
                : "border-slate-200 bg-white text-slate-400 hover:border-violet-200 hover:text-violet-500"
        }
        "
        data-timeline-index="${index}"
        data-action="click->entity-evolution-timeline#select">

        ${isCurrent ? "●" : index + 1}

      </button>

      <div class="mt-3 text-center">

        <div
          class="
            text-xs
            font-black
            ${
            isCurrent
                ? "text-violet-700"
                : "text-slate-700"
        }
          ">

          ${this.escapeHtml(version.version)}

        </div>

        ${
            version.label
                ? `
              <div
                class="
                  mt-0.5
                  text-[10px]
                  font-medium
                  text-slate-400
                ">

                ${this.escapeHtml(version.label)}

              </div>
            `
                : ""
        }

        ${
            version.date
                ? `
              <div
                class="
                  mt-1
                  text-[9px]
                  font-bold
                  uppercase
                  tracking-wider
                  text-slate-300
                ">

                ${this.escapeHtml(
                    this.formatDate(version.date)
                )}

              </div>
            `
                : ""
        }

      </div>

      <div
        class="
          mt-4
          w-full
          max-w-[150px]
        ">

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

          <span>Changes</span>

          <span>
            ${version.changes}
          </span>

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
            style="width: ${percentage}%">
          </div>

        </div>

      </div>

      ${
            version.milestone
                ? `
            <div
              class="
                mt-3
                rounded-full
                bg-amber-50
                px-2.5
                py-1
                text-[8px]
                font-black
                uppercase
                tracking-wider
                text-amber-600
              ">

              ✦ ${
                    this.escapeHtml(
                        version.milestoneLabel ||
                        "Milestone"
                    )
                }

            </div>
          `
                : ""
        }

    `

        return wrapper
    }

    select(event) {
        const index = Number(
            event.currentTarget.dataset.timelineIndex
        )

        if (
            Number.isNaN(index) ||
            index < 0 ||
            index >= this.versionsValue.length
        ) {
            return
        }

        this.currentIndex = index

        this.render()

        const version =
            this.normalizedVersions()[index]

        this.dispatch(
            "selected",
            {
                detail: {
                    version,
                    index
                }
            }
        )
    }

    previous() {
        if (this.currentIndex <= 0) return

        this.currentIndex -= 1

        this.render()

        this.dispatchSelection()
    }

    next() {
        if (
            this.currentIndex >=
            this.versionsValue.length - 1
        ) {
            return
        }

        this.currentIndex += 1

        this.render()

        this.dispatchSelection()
    }

    dispatchSelection() {
        const version =
            this.normalizedVersions()[this.currentIndex]

        this.dispatch(
            "selected",
            {
                detail: {
                    version,
                    index: this.currentIndex
                }
            }
        )
    }

    updateNavigation() {
        if (this.hasPreviousTarget) {
            this.previousTarget.disabled =
                this.currentIndex <= 0
        }

        if (this.hasNextTarget) {
            this.nextTarget.disabled =
                this.currentIndex >=
                this.versionsValue.length - 1
        }
    }

    updateSummary(version) {
        if (!this.hasSummaryTarget || !version) {
            return
        }

        this.summaryTarget.innerHTML = `
      <div
        class="
          flex
          flex-wrap
          items-center
          gap-3
        ">

        <span
          class="
            rounded-full
            bg-violet-50
            px-3
            py-1.5
            text-[9px]
            font-black
            uppercase
            tracking-wider
            text-violet-600
          ">

          ${this.escapeHtml(version.version)}

        </span>

        <span
          class="
            text-xs
            font-bold
            text-slate-500
          ">

          ${version.changes}
          recorded change${
            version.changes === 1 ? "" : "s"
        }

        </span>

      </div>
    `
    }

    renderEmpty() {
        this.timelineTarget.innerHTML = `
      <div
        class="
          w-full
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

        No version history is available yet.

      </div>
    `

        if (this.hasSummaryTarget) {
            this.summaryTarget.innerHTML = ""
        }
    }

    formatDate(value) {
        const date = new Date(value)

        if (Number.isNaN(date.getTime())) {
            return String(value)
        }

        return new Intl.DateTimeFormat(
            undefined,
            {
                year: "numeric",
                month: "short",
                day: "numeric"
            }
        ).format(date)
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