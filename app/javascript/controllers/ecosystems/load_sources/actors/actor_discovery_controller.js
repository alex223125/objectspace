import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "searchInput",
        "results",
        "loading",
        "spinner",
        "status",
        "empty",
        "loadedMessage",
        "resultCount"
    ]

    static values = {
        searchUrl: String
    }

    connect() {
        this.searchTimeout = null
        this.lastQuery = ""

        console.log("Actor discovery controller connected")

        this.updateInitialCount()
    }

    disconnect() {
        if (this.searchTimeout) {
            clearTimeout(this.searchTimeout)
        }
    }


    // ============================================================
    // SEARCH
    // ============================================================

    search(event) {
        const query = event.target.value.trim()

        this.lastQuery = query

        /*
         * Small debounce so Elasticsearch isn't queried
         * for every single keystroke.
         */
        if (this.searchTimeout) {
            clearTimeout(this.searchTimeout)
        }

        this.searchTimeout = setTimeout(() => {
            this.performSearch(query)
        }, 300)
    }


    // ============================================================
    // ELASTICSEARCH REQUEST
    // ============================================================

    async performSearch(query) {
        /*
         * Empty search returns the normal actor collection.
         */
        if (query.length === 0) {
            this.clearSearch()
            return
        }

        this.showLoading()

        this.showStatus(
            `Searching the actor ecosystem for "${query}"...`,
            "loading"
        )

        try {
            const url = new URL(this.searchUrlValue, window.location.origin)

            url.searchParams.set("q", query)

            const response = await fetch(url.toString(), {
                method: "GET",
                headers: {
                    "Accept": "application/json",
                    "X-Requested-With": "XMLHttpRequest"
                },
                credentials: "same-origin"
            })

            if (!response.ok) {
                throw new Error(
                    `Actor search failed with status ${response.status}`
                )
            }

            const data = await response.json()

            this.renderResults(data, query)

        } catch (error) {
            console.error("Actor discovery search error:", error)

            this.showError()
        }
    }


    // ============================================================
    // RENDER RESULTS
    // ============================================================

    renderResults(data, query) {
        const actors = data.actors || []

        this.hideLoading()

        this.resultsTarget.innerHTML = ""

        this.hideElement(this.emptyTarget)

        if (actors.length === 0) {
            this.showEmpty(query)
            this.updateResultCount(0)

            this.showStatus(
                `No entities found for "${query}".`,
                "empty"
            )

            return
        }


        /*
         * Render every Elasticsearch result.
         */
        actors.forEach((actor, index) => {
            const card = this.createActorCard(actor, index)

            this.resultsTarget.insertAdjacentHTML(
                "beforeend",
                card
            )
        })


        /*
         * Update counters.
         */
        this.updateResultCount(actors.length)


        /*
         * Tell the user that new entities arrived.
         */
        this.showLoadedMessage(
            actors.length,
            query
        )


        this.showStatus(
            `${actors.length} actor${actors.length === 1 ? "" : "s"} found.`,
            "success"
        )
    }


    // ============================================================
    // ACTOR CARD
    // ============================================================

    createActorCard(actor, index) {
        const name = this.escapeHtml(actor.name || "Unnamed actor")

        const description = this.escapeHtml(
            actor.description || "No description available yet."
        )

        const status = this.escapeHtml(
            actor.status || "draft"
        )

        const url = this.escapeAttribute(
            actor.url || "#"
        )

        const animationDelay = index * 60

        return `
      <article
        class="
          group
          relative
          overflow-hidden
          rounded-[28px]
          border-2 border-slate-100
          bg-white
          p-6
          shadow-sm
          transition-all
          duration-500
          hover:-translate-y-1
          hover:border-orange-200
          hover:shadow-lg
          hover:shadow-orange-100/60
        "
        style="animation: actorCardAppear 450ms ease-out ${animationDelay}ms both;"
      >

        <!-- Decorative glow -->

        <div
          class="
            pointer-events-none
            absolute
            -right-10
            -top-10
            h-28
            w-28
            rounded-full
            bg-orange-100/60
            blur-2xl
            transition-all
            duration-500
            group-hover:bg-orange-200/70
          "
        ></div>


        <!-- Header -->

        <div class="relative flex items-start justify-between gap-4">

          <div class="flex items-center gap-4">

            <!-- Actor icon -->

            <div
              class="
                flex
                h-12
                w-12
                shrink-0
                items-center
                justify-center
                rounded-[18px]
                border-2
                border-orange-200
                bg-orange-50
                text-xl
                shadow-sm
                transition-transform
                duration-300
                group-hover:scale-110
              "
            >
              🎭
            </div>


            <!-- Actor name -->

            <div>

              <h3
                class="
                  text-sm
                  font-black
                  text-slate-800
                "
              >
                ${name}
              </h3>

              <div
                class="
                  mt-1
                  text-[9px]
                  font-black
                  uppercase
                  tracking-widest
                  text-orange-500
                "
              >
                Actor entity
              </div>

            </div>

          </div>


          <!-- Status -->

          <span
            class="
              shrink-0
              rounded-full
              border
              border-emerald-200
              bg-emerald-50
              px-2.5
              py-1
              text-[9px]
              font-black
              uppercase
              tracking-wider
              text-emerald-600
            "
          >
            ${status}
          </span>

        </div>


        <!-- Description -->

        <p
          class="
            relative
            mt-5
            text-xs
            leading-6
            text-slate-400
          "
        >
          ${description}
        </p>


        <!-- Footer -->

        <div
          class="
            relative
            mt-6
            flex
            items-center
            justify-between
            border-t
            border-slate-100
            pt-4
          "
        >

          <div
            class="
              flex
              items-center
              gap-2
              text-[10px]
              font-bold
              text-orange-500
            "
          >

            <span
              class="
                h-2
                w-2
                rounded-full
                bg-orange-400
                shadow-[0_0_8px_rgba(251,146,60,0.7)]
              "
            ></span>

            Ecosystem entity

          </div>


          <a
            href="${url}"
            class="
              group/link
              flex
              items-center
              gap-2
              rounded-xl
              bg-slate-50
              px-3
              py-2
              text-[10px]
              font-black
              text-slate-500
              transition-all
              duration-300
              hover:bg-orange-50
              hover:text-orange-600
            "
          >

            Explore

            <span
              class="
                transition-transform
                duration-300
                group-hover/link:translate-x-1
              "
            >
              →
            </span>

          </a>

        </div>

      </article>
    `
    }


    // ============================================================
    // CLEAR SEARCH
    // ============================================================

    clearSearch() {
        this.hideLoading()

        this.hideElement(this.emptyTarget)

        this.hideElement(this.loadedMessageTarget)

        this.hideStatus()

        /*
         * Reload the normal index collection.
         *
         * We deliberately reload here rather than keeping a second
         * copy of the original collection inside JavaScript.
         */
        window.location.reload()
    }


    // ============================================================
    // LOADING
    // ============================================================

    showLoading() {
        this.showElement(this.loadingTarget)

        this.hideElement(this.resultsTarget)

        this.showSpinner()
    }


    hideLoading() {
        this.hideElement(this.loadingTarget)

        this.showElement(this.resultsTarget)

        this.hideSpinner()
    }


    showSpinner() {
        this.spinnerTarget.classList.remove("hidden")
        this.spinnerTarget.classList.add("flex")
    }


    hideSpinner() {
        this.spinnerTarget.classList.add("hidden")
        this.spinnerTarget.classList.remove("flex")
    }


    // ============================================================
    // STATUS
    // ============================================================

    showStatus(message, type = "default") {
        const colors = {
            loading: `
        border-orange-100
        bg-orange-50
        text-orange-600
      `,

            success: `
        border-emerald-100
        bg-emerald-50
        text-emerald-600
      `,

            empty: `
        border-slate-100
        bg-slate-50
        text-slate-500
      `,

            error: `
        border-red-100
        bg-red-50
        text-red-600
      `,

            default: `
        border-slate-100
        bg-slate-50
        text-slate-500
      `
        }

        this.statusTarget.className = `
      mt-4
      rounded-2xl
      border
      px-4
      py-3
      text-xs
      font-bold
      ${colors[type] || colors.default}
    `

        this.statusTarget.textContent = message

        this.showElement(this.statusTarget)
    }


    hideStatus() {
        this.hideElement(this.statusTarget)
    }


    // ============================================================
    // ENTITY LOADED MESSAGE
    // ============================================================

    showLoadedMessage(count, query) {
        const entityWord = count === 1 ? "entity" : "entities"

        this.loadedMessageTarget.innerHTML = `
      <div
        class="
          flex
          flex-col
          gap-4
          rounded-[26px]
          border-2
          border-emerald-100
          bg-gradient-to-r
          from-emerald-50
          via-white
          to-orange-50
          px-5
          py-4
          shadow-sm
          md:flex-row
          md:items-center
          md:justify-between
        "
      >

        <div class="flex items-center gap-4">

          <div
            class="
              flex
              h-11
              w-11
              shrink-0
              items-center
              justify-center
              rounded-2xl
              bg-emerald-100
              text-lg
              shadow-sm
            "
          >
            ✨
          </div>

          <div>

            <div
              class="
                text-sm
                font-black
                text-emerald-700
              "
            >
              ${count} ${entityWord} loaded
            </div>

            <div
              class="
                mt-1
                text-xs
                text-slate-400
              "
            >
              Discovery engine found matching actors for
              <span class="font-bold text-slate-500">
                "${this.escapeHtml(query)}"
              </span>
            </div>

          </div>

        </div>


        <div
          class="
            rounded-full
            border
            border-emerald-200
            bg-white
            px-3
            py-1.5
            text-[9px]
            font-black
            uppercase
            tracking-widest
            text-emerald-500
          "
        >
          +${count} discovered
        </div>

      </div>
    `

        this.showElement(this.loadedMessageTarget)

        /*
         * Small gamification animation.
         */
        this.loadedMessageTarget.animate(
            [
                {
                    opacity: 0,
                    transform: "translateY(-8px) scale(0.98)"
                },
                {
                    opacity: 1,
                    transform: "translateY(0) scale(1)"
                }
            ],
            {
                duration: 450,
                easing: "cubic-bezier(0.22, 1, 0.36, 1)"
            }
        )
    }


    // ============================================================
    // EMPTY
    // ============================================================

    showEmpty(query) {
        this.hideLoading()

        this.resultsTarget.innerHTML = ""

        this.emptyTarget.innerHTML = `
      <div
        class="
          rounded-[30px]
          border-2
          border-dashed
          border-slate-200
          bg-slate-50/70
          px-6
          py-14
          text-center
        "
      >

        <div
          class="
            mx-auto
            mb-4
            flex
            h-16
            w-16
            items-center
            justify-center
            rounded-[24px]
            bg-slate-100
            text-2xl
          "
        >
          🔭
        </div>

        <h2
          class="
            text-sm
            font-black
            text-slate-700
          "
        >
          No actors found
        </h2>

        <p
          class="
            mx-auto
            mt-2
            max-w-md
            text-xs
            leading-6
            text-slate-400
          "
        >
          Nothing matched
          <strong>"${this.escapeHtml(query)}"</strong>.
          Try another discovery signal.
        </p>

      </div>
    `

        this.hideElement(this.resultsTarget)

        this.showElement(this.emptyTarget)
    }


    // ============================================================
    // ERROR
    // ============================================================

    showError() {
        this.hideLoading()

        this.resultsTarget.innerHTML = ""

        this.showStatus(
            "The actor discovery engine could not complete the search. Please try again.",
            "error"
        )

        this.resultsTarget.innerHTML = `
      <div
        class="
          md:col-span-2
          xl:col-span-3
          rounded-[30px]
          border-2
          border-red-100
          bg-red-50/50
          px-6
          py-12
          text-center
        "
      >

        <div
          class="
            mx-auto
            mb-4
            flex
            h-14
            w-14
            items-center
            justify-center
            rounded-[22px]
            bg-red-100
            text-xl
          "
        >
          ⚠️
        </div>

        <div
          class="
            text-sm
            font-black
            text-red-600
          "
        >
          Discovery temporarily unavailable
        </div>

        <p
          class="
            mt-2
            text-xs
            text-slate-400
          "
        >
          Please try the search again.
        </p>

      </div>
    `
    }


    // ============================================================
    // COUNTERS
    // ============================================================

    updateInitialCount() {
        if (!this.hasResultCountTarget) {
            return
        }

        const count = this.resultsTarget.querySelectorAll(
            "article"
        ).length

        this.updateResultCount(count)
    }


    updateResultCount(count) {
        if (!this.hasResultCountTarget) {
            return
        }

        this.resultCountTarget.textContent =
            `${count} ${count === 1 ? "entity" : "entities"} discovered`
    }


    // ============================================================
    // DOM HELPERS
    // ============================================================

    showElement(element) {
        if (!element) {
            return
        }

        element.classList.remove("hidden")
    }


    hideElement(element) {
        if (!element) {
            return
        }

        element.classList.add("hidden")
    }


    // ============================================================
    // SECURITY HELPERS
    // ============================================================

    escapeHtml(value) {
        const div = document.createElement("div")

        div.textContent = value

        return div.innerHTML
    }


    escapeAttribute(value) {
        return this.escapeHtml(value)
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;")
    }
}
