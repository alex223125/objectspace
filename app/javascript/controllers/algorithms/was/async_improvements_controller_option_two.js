import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    // Bind semantic targets explicitly mapping your form and feed elements
    static targets = [ "feedContainer", "titleInput", "contentInput", "sourcesInput", "errorBlock", "loadMoreButton" ]
    // Maps route string data and state trackers extracted from the view layer
    static values = {
        endpoint: String,
        page: { type: Number, default: 1 },
        hasMore: { type: Boolean, default: true }
    }
    connect() {
        console.log("Async improvements controller connected")
        // Initialize fallback default state metrics if missing from HTML attributes
        if (!this.hasPageValue) this.pageValue = 1
        if (!this.hasHasMoreValue) this.hasMoreValue = true

        // Populate layout feed log metrics instantly on component initialization
        this.refreshFeed()
    }

    // Issue non-blocking query request streams to fetch initial database allocations
    async refreshFeed() {
        this.pageValue = 1
        this.hasMoreValue = true
        if (this.hasLoadMoreButtonTarget) this.loadMoreButtonTarget.classList.remove("hidden")

        try {
            const url = new URL(this.endpointValue, window.location.origin)
            url.searchParams.set("page", this.pageValue) // Natively chooses between '?' or '&' perfectly

            const response = await fetch(url.toString(), {
                headers: {
                    "Accept": "application/json",
                    "X-Requested-With": "XMLHttpRequest"
                }
            })
            
            if (!response.ok) throw new Error("API stream transaction disruption exception")

            const data = await response.json()

            // Normalize layout arrays vs paginated object structures safely
            const items = Array.isArray(data) ? data : (data.improvements || [])
            const serverHasMore = data.has_more !== undefined ? data.has_more : items.length >= 5

            this.renderFeed(items)

            if (!serverHasMore) {
                this.hasMoreValue = false
                if (this.hasLoadMoreButtonTarget) this.loadMoreButtonTarget.classList.add("hidden")
            }
        } catch (error) {
            console.error("Async telemetry logging error:", error)
            this.feedContainerTarget.innerHTML = `
        <div class="p-4 text-center font-mono text-xs text-red-500 bg-red-500/10 border border-red-500/20 rounded-xl border-dashed">
          // Execution Error: Failed to synchronize remote log caches.
        </div>`
        }
    }

    // Appends subsequent log entries dynamically down to the bottom of the grid
    async loadMore() {
        if (!this.hasMoreValue) return;

        this.pageValue++; // Move to page 2, 3, etc.
        console.log(`Fetching page range: ${this.pageValue}`);

        const originalText = this.loadMoreButtonTarget.innerHTML;
        this.loadMoreButtonTarget.innerHTML = "<span>⚡</span> FETCHING_DATA_SEQUENCE...";
        this.loadMoreButtonTarget.disabled = true;

        try {
            // Safe URL parser splits out existing string tokens to prevent concatenation bugs
            const url = new URL(this.endpointValue, window.location.origin);
            url.searchParams.set("page", this.pageValue);

            const response = await fetch(url.toString(), {
                headers: {
                    "Accept": "application/json",
                    "X-Requested-With": "XMLHttpRequest"
                }
            });

            if (!response.ok) throw new Error(`HTTP Error Status: ${response.status}`);

            const improvements = await response.json();
            console.log("Appended collection data:", improvements);

            if (improvements.length === 0) {
                this.hasMoreValue = false;
                this.loadMoreButtonTarget.classList.add("hidden");
                return;
            }

            // Append cards to bottom element slots seamlessly
            const additionalCardsHtml = improvements.map(item => this.buildCardHtml(item)).join("");
            this.feedContainerTarget.insertAdjacentHTML("beforeend", additionalCardsHtml);

            if (improvements.length < 5) {
                this.hasMoreValue = false;
                this.loadMoreButtonTarget.classList.add("hidden");
            }

        } catch (error) {
            console.error("Pagination engine crash exception trace:", error);
        } finally {
            if (this.hasMoreValue && this.hasLoadMoreButtonTarget) {
                this.loadMoreButtonTarget.innerHTML = originalText;
                this.loadMoreButtonTarget.disabled = false;
            }
        }
    }

    // Unpack individual objects or load baseline fallback placeholders
    renderFeed(items) {
        if (items.length === 0) {
            this.feedContainerTarget.innerHTML = `
        <div class="p-6 text-center bg-gray-50/50 dark:bg-gray-900/30 rounded-md border border-dashed border-gray-200 dark:border-gray-800 text-xs font-mono text-gray-500">
          [ NO_ACTIVE_LOG_SEQUENCES_FOUND ]
        </div>`
            if (this.hasLoadMoreButtonTarget) this.loadMoreButtonTarget.classList.add("hidden")
            return
        }

        this.feedContainerTarget.innerHTML = items.map(item => this.buildCardHtml(item)).join("")
    }

    // Pure blueprint layout generator mapping object strings securely (Slim, Premium Style)
    buildCardHtml(item) {
        const titleText = item.title || "EMPTY_ID"
        const isTruncated = titleText.length > 24
        const displayTitle = isTruncated ? `${titleText.substring(0, 24)}...` : titleText
        const payloadText = item.content || "No dynamic payload returned."

        return `
    <div class="group relative flex items-center justify-between p-2.5 bg-gray-50/50 dark:bg-gray-950/40 border border-gray-200/60 dark:border-gray-800/60 rounded-md transition-all hover:bg-white dark:hover:bg-gray-900/60 hover:border-cyan-500/40 shadow-sm overflow-hidden animate-fade-in">
      <div class="absolute left-0 top-0 bottom-0 w-[2px] bg-cyan-500 scale-y-0 group-hover:scale-y-100 transition-transform duration-200 origin-top"></div>
      
      <div class="flex items-center gap-3 pl-1">
        <span class="text-[10px] text-cyan-500/40 group-hover:text-cyan-500 transition-colors">▶</span>
        <div class="flex flex-col">
          <h4 class="text-xs font-bold ${item.title ? 'text-gray-800 dark:text-gray-200' : 'text-gray-400 dark:text-gray-600 italic'} tracking-tight group-hover:text-cyan-400 transition-colors" title="${this.escapeHtml(titleText)}">
            # ${this.escapeHtml(displayTitle)}
          </h4>
          <span class="text-[10px] text-gray-400 dark:text-gray-500 mt-0.5 font-sans">
            ${this.escapeHtml(payloadText)}
          </span>
        </div>
      </div>
      
      <div class="flex items-center gap-2">
        <span class="text-[9px] font-semibold bg-gray-100 dark:bg-gray-900 text-gray-500 dark:text-gray-400 px-1.5 py-0.5 rounded border border-gray-200/40 dark:border-gray-800/40 whitespace-nowrap">
          ● <span class="font-sans text-[10px] ml-0.5">${item.created_at || 'Just now'}</span>
        </span>
      </div>
    </div>`
    }

    // Direct behavioral action triggered when your form submits
    async deployModification(event) {
        event.preventDefault() // Prevents raw browser page reloads

        // 1. Sync TinyMCE contents back into underlying textarea targets
        if (typeof tinymce !== 'undefined') {
            tinymce.triggerSave()
        }

        const payload = {
            improvement: {
                title: this.titleInputTarget.value,
                content: this.contentInputTarget.value, // FIXED: Corrected mapping target
                sources: this.sourcesInputTarget.value
            }
        }

        try {
            const response = await fetch(this.endpointValue, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
                },
                body: JSON.stringify(payload)
            })

            const data = await response.json()

            if (data.success || response.status === 201) {
                // Prepend newly created records onto top slot of the view area
                const placeholder = this.feedContainerTarget.querySelector(".animate-pulse, .border-dashed")
                if (placeholder) this.feedContainerTarget.innerHTML = ""

                const newCardHtml = this.buildCardHtml(data.improvement)
                this.feedContainerTarget.insertAdjacentHTML('afterbegin', newCardHtml)

                // Enforce safety boundary on top list buffer max lengths if required
                if (this.feedContainerTarget.children.length > 25) {
                    this.feedContainerTarget.children[this.feedContainerTarget.children.length - 1].remove()
                }

                // 2. Clear out inputs
                this.titleInputTarget.value = ""
                this.contentInputTarget.value = ""
                this.sourcesInputTarget.value = ""

                if (typeof tinymce !== 'undefined' && tinymce.activeEditor) {
                    tinymce.activeEditor.setContent('')
                }

                // 3. New notification trigger engine execution block
                this.triggerVisualCongratulations(data.message || "System layout patch deployment successful!")
            } else {
                // Output fallback errors to layout container alert node
                if (this.hasErrorBlockTarget) {
                    this.errorBlockTarget.innerText = data.errors?.join(", ") || "Unknown compilation exception."
                    this.errorBlockTarget.classList.remove("hidden")
                }
            }
        } catch (error) {
            console.error("DOM Mutation Failed:", error)
        }
    }

    escapeHtml(string) {
        const div = document.createElement('div')
        div.innerText = string || ""
        return div.innerHTML
    }

    // ====================================================================
    // VISUAL CONGRATULATIONS NOTIFICATION TOAST ENGINE
    // ====================================================================
    triggerVisualCongratulations(successMessage) {
        const anchorNode = document.getElementById("gamified-notification-anchor");
        if (!anchorNode) return;

        // Unique timestamp tracking string creation to avoid multi-submit collision overlays
        const toastId = `toast-${Date.now()}`;

        const toastHtml = `
    <div id="${toastId}" 
         role="alert"
         class="pointer-events-auto flex items-start w-full p-4 text-gray-900 bg-white border border-gray-200 rounded-xl shadow-xl dark:bg-gray-800 dark:border-gray-700 dark:text-gray-300 transform -translate-y-12 opacity-0 transition-all duration-500 ease-out">
      
      <div class="inline-flex items-center justify-center flex-shrink-0 w-8 h-8 text-green-500 bg-green-100 rounded-lg dark:bg-green-900/40 dark:text-green-400">
        <svg class="w-4 h-4" aria-hidden="true" xmlns="http://w3.org" fill="currentColor" viewBox="0 0 20 20">
          <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 8.207-4 4a1 1 0 0 1-1.414 0l-2-2a1 1 0 0 1 1.414-1.414L9 10.586l3.293-3.293a1 1 0 0 1 1.414 1.414Z"/>
        </svg>
        <span class="sr-only">Success Icon</span>
      </div>
      
      <div class="ml-3 flex-1 pt-0.5">
        <div class="text-xs font-mono font-black text-gray-400 dark:text-gray-500 uppercase tracking-wider">
          // STATUS_CODE: 201_CREATED
        </div>
        <div class="text-sm font-bold text-gray-900 dark:text-white mt-0.5">
          System Refinement Logged
        </div>
        <p class="text-xs font-medium text-gray-600 dark:text-gray-400 mt-1 leading-relaxed">
          ${this.escapeHtml(successMessage)}
        </p>
      </div>

      <button type="button" 
              onclick="document.getElementById('${toastId}').remove()" 
              class="ml-4 -mx-1.5 -my-1.5 bg-transparent border-0 text-gray-400 hover:text-gray-900 rounded-lg focus:ring-2 focus:ring-gray-300 p-1.5 hover:bg-gray-100 inline-flex items-center justify-center h-8 w-8 dark:text-gray-500 dark:hover:text-white dark:hover:bg-gray-700 cursor-pointer transition-colors" 
              aria-label="Close">
        <span class="sr-only">Dismiss</span>
        <svg class="w-3 h-3" aria-hidden="true" xmlns="http://w3.org" fill="none" viewBox="0 0 14 14">
          <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"/>
        </svg>
      </button>
    </div>
  `;

        // Append component into the top layout slot viewport
        anchorNode.insertAdjacentHTML("beforeend", toastHtml);

        // Micro-timeout allows browser DOM layout to register base tags prior to initiating animations
        setTimeout(() => {
            const activeToast = document.getElementById(toastId);
            if (activeToast) {
                activeToast.classList.remove("-translate-y-12", "opacity-0");
                activeToast.classList.add("translate-y-0", "opacity-100");
            }
        }, 50);

        // Automated self-destruct function execution mapping sequence to clear window space after 5 seconds
        setTimeout(() => {
            const activeToast = document.getElementById(toastId);
            if (activeToast) {
                activeToast.classList.remove("translate-y-0", "opacity-100");
                activeToast.classList.add("-translate-y-12", "opacity-0");
                setTimeout(() => activeToast.remove(), 500);
            }
        }, 5000);
    }
}