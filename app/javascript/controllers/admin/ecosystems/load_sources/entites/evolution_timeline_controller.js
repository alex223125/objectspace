import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "version",
        "detail",
        "selectedVersion",
        "progress",
        "focusButton"
    ]

    connect() {
        this.currentIndex = this.versionTargets.findIndex(
            (element) => element.dataset.current === "true"
        )

        if (this.currentIndex < 0) {
            this.currentIndex = this.versionTargets.length - 1
        }

        this.select(this.currentIndex, false)

        this.keydownHandler = (event) => this.handleKeydown(event)

        window.addEventListener("keydown", this.keydownHandler)
    }

    disconnect() {
        window.removeEventListener("keydown", this.keydownHandler)
    }

    select(index, scroll = true) {
        if (!this.versionTargets.length) return

        index = Math.max(0, Math.min(index, this.versionTargets.length - 1))

        this.currentIndex = index

        this.versionTargets.forEach((element, elementIndex) => {
            const selected = elementIndex === index

            element.classList.toggle("ring-4", selected)
            element.classList.toggle("ring-orange-100", selected)
            element.classList.toggle("scale-[1.03]", selected)
            element.setAttribute("aria-selected", selected.toString())

            const marker = element.querySelector("[data-timeline-marker]")

            if (marker) {
                marker.classList.toggle("scale-110", selected)
                marker.classList.toggle("shadow-lg", selected)
            }
        })

        const selected = this.versionTargets[index]

        if (this.hasSelectedVersionTarget) {
            this.selectedVersionTarget.textContent =
                selected.dataset.title || `Version ${index + 1}`
        }

        if (this.hasDetailTarget) {
            this.detailTarget.innerHTML = selected.dataset.detail || ""
        }

        if (this.hasProgressTarget) {
            const percentage =
                this.versionTargets.length <= 1
                    ? 100
                    : (index / (this.versionTargets.length - 1)) * 100

            this.progressTarget.style.width = `${percentage}%`
        }

        if (scroll) {
            selected.scrollIntoView({
                behavior: this.reducedMotion ? "auto" : "smooth",
                block: "nearest",
                inline: "center"
            })
        }
    }

    previous() {
        this.select(this.currentIndex - 1)
    }

    next() {
        this.select(this.currentIndex + 1)
    }

    focusCurrent() {
        this.select(this.currentIndex)

        const selected = this.versionTargets[this.currentIndex]

        selected?.focus({
            preventScroll: false
        })
    }

    focusHighestActivity() {
        if (!this.versionTargets.length) return

        let highestIndex = 0
        let highestActivity = -1

        this.versionTargets.forEach((element, index) => {
            const activity = Number(element.dataset.activity || 0)

            if (activity > highestActivity) {
                highestActivity = activity
                highestIndex = index
            }
        })

        this.select(highestIndex)
        this.focusCurrent()
    }

    handleKeydown(event) {
        const tag = event.target?.tagName?.toLowerCase()

        if (
            tag === "input" ||
            tag === "textarea" ||
            tag === "select" ||
            event.target?.isContentEditable
        ) {
            return
        }

        if (!this.element.matches(":focus-within")) {
            return
        }

        switch (event.key) {
            case "ArrowLeft":
                event.preventDefault()
                this.previous()
                break

            case "ArrowRight":
                event.preventDefault()
                this.next()
                break

            case "Home":
                event.preventDefault()
                this.select(0)
                break

            case "End":
                event.preventDefault()
                this.select(this.versionTargets.length - 1)
                break

            case "f":
            case "F":
                event.preventDefault()
                this.focusHighestActivity()
                break
        }
    }

    get reducedMotion() {
        return window.matchMedia(
            "(prefers-reduced-motion: reduce)"
        ).matches
    }
}