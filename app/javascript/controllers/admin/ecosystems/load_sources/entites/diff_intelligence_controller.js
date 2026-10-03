import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "progressBar",
        "progressValue",
        "signalList",
        "badgeList",
        "toast",
        "toastTitle",
        "toastMessage"
    ]

    static values = {
        progress: Number,
        autoAnimate: {
            type: Boolean,
            default: true
        }
    }

    connect() {
        this.renderProgress()
        this.animateSignals()
        this.animateBadges()
    }

    renderProgress() {
        if (!this.hasProgressBarTarget) return

        const score = Math.max(
            0,
            Math.min(100, Number(this.progressValue) || 0)
        )

        requestAnimationFrame(() => {
            this.progressBarTarget.style.width = `${score}%`
        })

        if (this.hasProgressValueTarget) {
            this.progressValueTarget.textContent = `${score}%`
        }
    }

    animateSignals() {
        if (!this.hasSignalListTarget || !this.autoAnimateValue) return

        const items = this.signalListTarget.querySelectorAll(
            "[data-diff-intelligence-signal]"
        )

        items.forEach((item, index) => {
            item.style.opacity = "0"
            item.style.transform = "translateY(8px)"

            setTimeout(() => {
                item.style.transition =
                    "opacity 300ms ease, transform 300ms ease"

                item.style.opacity = "1"
                item.style.transform = "translateY(0)"
            }, index * 80)
        })
    }

    animateBadges() {
        if (!this.hasBadgeListTarget || !this.autoAnimateValue) return

        const items = this.badgeListTarget.querySelectorAll(
            "[data-diff-intelligence-badge]"
        )

        items.forEach((item, index) => {
            item.style.opacity = "0"
            item.style.transform = "scale(.96)"

            setTimeout(() => {
                item.style.transition =
                    "opacity 300ms ease, transform 300ms ease"

                item.style.opacity = "1"
                item.style.transform = "scale(1)"
            }, 150 + index * 100)
        })
    }

    showSignal(event) {
        const element = event.currentTarget

        const title =
            element.dataset.signalTitle || "Semantic signal"

        const message =
            element.dataset.signalMessage || ""

        this.showToast(title, message)
    }

    showBadge(event) {
        const element = event.currentTarget

        const title =
            element.dataset.badgeTitle || "Achievement"

        const message =
            element.dataset.badgeMessage || ""

        this.showToast(title, message)
    }

    showToast(title, message) {
        if (!this.hasToastTarget) return

        if (this.hasToastTitleTarget) {
            this.toastTitleTarget.textContent = title
        }

        if (this.hasToastMessageTarget) {
            this.toastMessageTarget.textContent = message
        }

        this.toastTarget.classList.remove(
            "opacity-0",
            "pointer-events-none",
            "translate-y-3"
        )

        this.toastTarget.classList.add(
            "opacity-100",
            "translate-y-0"
        )

        clearTimeout(this.toastTimer)

        this.toastTimer = setTimeout(() => {
            this.toastTarget.classList.remove(
                "opacity-100",
                "translate-y-0"
            )

            this.toastTarget.classList.add(
                "opacity-0",
                "pointer-events-none",
                "translate-y-3"
            )
        }, 3200)
    }
}