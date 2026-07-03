import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    // Bind semantic targets explicitly mapping your form elements
    static targets = [ "feedContainer", "titleInput", "descriptionInput", "sourcesInput", "errorBlock" ]
    // Maps route string data extracted from the application show view layer
    static values = { endpoint: String }

    connect() {
        console.log("Async improvements controller connected")
        // Populate layout feed log metrics instantly on component initialization
        this.refreshFeed()
    }

    // Issue non-blocking query request streams to fetch active database allocations
    async refreshFeed() {
        try {
            const response = await fetch(this.endpointValue, {
                headers: {
                    "Accept": "application/json",
                    "X-Requested-With": "XMLHttpRequest"
                }
            })
            if (!response.ok) throw new Error("API stream transaction disruption exception")

            const improvements = await response.json()
            this.renderFeed(improvements)
        } catch (error) {
            console.error("Async telemetry logging error:", error)
            this.feedContainerTarget.innerHTML = `
        <div class="p-4 text-center font-mono text-xs text-red-500 bg-red-500/10 border border-red-500/20 rounded-xl">
          // Execution Error: Failed to synchronize remote log caches.
        </div>`
        }
    }

    // Unpack individual objects or load baseline fallback placeholders
    renderFeed(items) {
        if (items.length === 0) {
            this.feedContainerTarget.innerHTML = `
        <div class="p-6 text-center bg-gray-50/50 dark:bg-gray-900/30 rounded-xl border border-dashed border-gray-200 dark:border-gray-800 text-xs font-mono text-gray-500">
          // No refinements currently logged. Initialize structural code upgrade below.
        </div>`
            return
        }

        this.feedContainerTarget.innerHTML = items.map(item => this.buildCardHtml(item)).join("")
    }

    // Pure blueprint layout generator mapping object strings securely
    buildCardHtml(item) {
        return `
      <div class="p-4 bg-white dark:bg-gray-950 border border-gray-200 dark:border-gray-800/80 rounded-xl shadow-sm transition-all hover:border-cyan-500/30 animate-fade-in">
        <div class="flex items-center justify-between gap-4 mb-2">
          <h4 class="text-sm font-bold text-gray-900 dark:text-white font-mono"># ${this.escapeHtml(item.title)}</h4>
          <span class="text-[10px] font-mono font-semibold bg-gray-100 dark:bg-gray-900 text-gray-500 dark:text-gray-400 px-2 py-0.5 rounded-md">
            ${item.created_at}
          </span>
        </div>
        <p class="text-xs text-gray-600 dark:text-gray-400 font-sans leading-relaxed whitespace-pre-wrap">${this.escapeHtml(item.description)}</p>
      </div>`
    }

// This is the direct behavioral action triggered when your form submits
    async deployModification(event) {
        event.preventDefault() // Prevents the browser from reloading the page

        // 1. Sync TinyMCE contents back into the underlying textarea element
        if (typeof tinymce !== 'undefined') {
            tinymce.triggerSave()
        }

        const payload = {
            improvement: {
                title: this.titleInputTarget.value,
                description: this.sourcesInputTarget.value
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

            // ====================================================================
            // THE DYNAMIC TRIGGER BEHAVIOR STARTS HERE
            // ====================================================================

            if (data.success || response.status === 201) {

                // 1. Existing DOM updates: Prepend newly created item node onto log lists
                const placeholder = this.feedContainerTarget.querySelector(".animate-pulse, .border-dashed")
                if (placeholder) this.feedContainerTarget.innerHTML = ""

                const newCardHtml = this.buildCardHtml(data.improvement)
                this.feedContainerTarget.insertAdjacentHTML('afterbegin', newCardHtml)

                if (this.feedContainerTarget.children.length > 5) {
                    this.feedContainerTarget.children[this.feedContainerTarget.children.length - 1].remove()
                }

                // 2. Clear input areas out of form textareas
                this.titleInputTarget.value = ""
                this.descriptionInputTarget.value = ""
                if (typeof tinymce !== 'undefined' && tinymce.activeEditor) {
                    tinymce.activeEditor.setContent('')
                }

                // ====================================================================
                // NEW WORKSPACE TRIGGER: VISUAL CONGRATULATIONS NOTIFICATION ENGINE
                // ====================================================================
                this.triggerVisualCongratulations(data.message || "System layout patch deployment successful!")

            }

        } catch (error) {
            console.error("DOM Mutation Failed:", error)
        }
    }

    // Helper mapping blueprint to build uniform list item cards cleanly
    buildCardHtml(item) {
        return `
      <div class="p-4 bg-white dark:bg-gray-950 border border-gray-200 dark:border-gray-800/80 rounded-xl shadow-sm transition-all hover:border-cyan-500/30 animate-fade-in">
        <div class="flex items-center justify-between gap-4 mb-2">
          <h4 class="text-sm font-bold text-gray-900 dark:text-white font-mono"># ${this.escapeHtml(item.title)}</h4>
          <span class="text-[10px] font-mono font-semibold bg-gray-100 dark:bg-gray-900 text-gray-500 dark:text-gray-400 px-2 py-0.5 rounded-md">
            ${item.created_at || 'Just now'}
          </span>
        </div>
        <p class="text-xs text-gray-600 dark:text-gray-400 font-sans leading-relaxed whitespace-pre-wrap">${this.escapeHtml(item.description)}</p>
      </div>`
    }

    escapeHtml(string) {
        const div = document.createElement('div')
        div.innerText = string || ""
        return div.innerHTML
    }

    triggerVisualCongratulations(successMessage) {
        const anchorNode = document.getElementById("gamified-notification-anchor");
        if (!anchorNode) return;

        // Unique timestamp ID string creation to avoid multi-submit collision overlays
        const toastId = `toast-${Date.now()}`;

        const toastHtml = `
    <div id="${toastId}" 
         role="alert"
         class="pointer-events-auto flex items-start w-full p-4 text-gray-900 bg-white border border-gray-200 rounded-xl shadow-xl dark:bg-gray-800 dark:border-gray-700 dark:text-gray-300 transform -translate-y-12 opacity-0 transition-all duration-500 ease-out">
      
      <!-- System Notification Accent Icon Wrapper -->
      <div class="inline-flex items-center justify-center flex-shrink-0 w-8 h-8 text-green-500 bg-green-100 rounded-lg dark:bg-green-900/40 dark:text-green-400">
        <svg class="w-4 h-4" aria-hidden="true" xmlns="http://w3.org" fill="currentColor" viewBox="0 0 20 20">
          <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 8.207-4 4a1 1 0 0 1-1.414 0l-2-2a1 1 0 0 1 1.414-1.414L9 10.586l3.293-3.293a1 1 0 0 1 1.414 1.414Z"/>
        </svg>
        <span class="sr-only">Success Icon</span>
      </div>
      
      <!-- Documentation Metadata Information Block Mapping Matrix -->
      <div class="ml-3 flex-1 pt-0.5">
        <div class="text-xs font-mono font-black text-gray-400 dark:text-gray-500 uppercase tracking-wider">
          // STATUS_CODE: 201_CREATED
        </div>
        <div class="text-sm font-bold text-gray-900 dark:text-white mt-0.5">
          System Refinement Logged
        </div>
        <p class="text-xs font-medium text-gray-600 dark:text-gray-400 mt-1 leading-relaxed">
          ${successMessage}
        </p>
      </div>

      <!-- High-Utility Dismiss Button Trigger Anchor Node -->
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
