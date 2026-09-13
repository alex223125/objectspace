import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "toast",
        "toastIcon",
        "toastTitle",
        "toastMessage"
    ]

    connect() {
        this.hideTimer = null
    }

    show(message, options = {}) {
        const {
            title = "DEFINITION UPDATED",
            icon = "✦",
            tone = "violet",
            duration = 2200
        } = options

        if (!this.hasToastTarget) return

        this.toastTitleTarget.textContent = title
        this.toastMessageTarget.textContent = message
        this.toastIconTarget.textContent = icon

        this.applyTone(tone)

        this.toastTarget.classList.remove("hidden")
        this.toastTarget.classList.add("animate-[fadeIn_0.2s_ease-out]")

        clearTimeout(this.hideTimer)

        this.hideTimer = setTimeout(() => {
            this.hide()
        }, duration)
    }

    success(message, title = "MISSION UPDATED") {
        this.show(message, {
            title,
            icon: "✓",
            tone: "emerald"
        })
    }

    info(message, title = "DEFINITION UPDATED") {
        this.show(message, {
            title,
            icon: "✦",
            tone: "violet"
        })
    }

    warning(message, title = "CHECK REQUIRED") {
        this.show(message, {
            title,
            icon: "⚠",
            tone: "orange",
            duration: 3500
        })
    }

    error(message, title = "DEFINITION ERROR") {
        this.show(message, {
            title,
            icon: "!",
            tone: "red",
            duration: 4500
        })
    }

    syncing(message = "Synchronizing definition...") {
        this.show(message, {
            title: "SYNCING",
            icon: "↻",
            tone: "sky",
            duration: 1400
        })
    }

    hide() {
        if (!this.hasToastTarget) return

        this.toastTarget.classList.add("hidden")
        this.toastTarget.classList.remove("animate-[fadeIn_0.2s_ease-out]")
    }

    applyTone(tone) {
        if (!this.hasToastTarget) return

        const container = this.toastTarget.querySelector("[data-notification-container]")
        if (!container) return

        const tones = {
            violet: [
                "border-violet-100",
                "bg-white",
                "shadow-violet-200/40"
            ],
            emerald: [
                "border-emerald-100",
                "bg-white",
                "shadow-emerald-200/40"
            ],
            orange: [
                "border-orange-100",
                "bg-white",
                "shadow-orange-200/40"
            ],
            red: [
                "border-red-100",
                "bg-white",
                "shadow-red-200/40"
            ],
            sky: [
                "border-sky-100",
                "bg-white",
                "shadow-sky-200/40"
            ]
        }

        const allClasses = Object.values(tones).flat()

        container.classList.remove(...allClasses)
        container.classList.add(...(tones[tone] || tones.violet))
    }
}