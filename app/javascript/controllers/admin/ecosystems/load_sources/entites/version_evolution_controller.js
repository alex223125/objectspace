// app/javascript/controllers/version_evolution_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "node",
        "card",
        "inspector",
        "position",
        "previousButton",
        "nextButton",
        "selectedLabel",
        "selectedDate",
        "selectedChanges",
        "selectedIntensity",
        "selectedSummary",
        "selectedStatus",
        "selectedReview",
        "compareButton",
        "progress",
        "liveRegion"
    ]

    static values = {
        selected: Number
    }

    connect() {
        this.currentIndex = this.initialIndex()

        this.select(this.currentIndex, false)

        this.handleKeydown = this.handleKeydown.bind(this)

        this.element.addEventListener("keydown", this.handleKeydown)
    }

    disconnect() {
        this.element.removeEventListener("keydown", this.handleKeydown)
    }

    initialIndex() {
        const current = this.nodeTargets.findIndex((node) => {
            return node.dataset.current === "true"
        })

        if (current >= 0) return current

        return Math.max(this.nodeTargets.length - 1, 0)
    }

    handleKeydown(event) {
        // Do not hijack typing in inputs/textareas.
        if (
            event.target.matches("input, textarea, select") ||
            event.target.isContentEditable
        ) {
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
                this.select(this.nodeTargets.length - 1)
                break

            case "Enter":
            case " ":
                if (event.target.matches("[data-version-evolution-target='node']")) {
                    event.preventDefault()
                    this.select(this.nodeTargets.indexOf(event.target))
                }
                break
        }
    }

    previous() {
        if (this.currentIndex <= 0) return

        this.select(this.currentIndex - 1)
    }

    next() {
        if (this.currentIndex >= this.nodeTargets.length - 1) return

        this.select(this.currentIndex + 1)
    }

    select(indexOrEvent, announce = true) {
        if (!this.nodeTargets.length) return

        let index = indexOrEvent

        if (typeof indexOrEvent === "object") {
            const node = indexOrEvent.currentTarget

            index = this.nodeTargets.indexOf(node)
        }

        const safeIndex = Math.max(
            0,
            Math.min(Number(index), this.nodeTargets.length - 1)
        )

        this.currentIndex = safeIndex

        const node = this.nodeTargets[safeIndex]
        const data = node.dataset

        this.selectedValue = safeIndex

        this.nodeTargets.forEach((item, itemIndex) => {
            const active = itemIndex === safeIndex

            item.setAttribute(
                "aria-selected",
                active ? "true" : "false"
            )

            item.classList.toggle(
                "ring-4",
                active
            )

            item.classList.toggle(
                "ring-orange-200",
                active
            )

            item.classList.toggle(
                "scale-105",
                active
            )

            item.classList.toggle(
                "z-20",
                active
            )
        })

        this.updateInspector(data)
        this.updateNavigation()
        this.updateProgress()

        if (announce) {
            this.announce(
                `${data.label || "Version"} selected. ${data.changes || 0} changes.`
            )
        }

        this.scrollNodeIntoView(node)
    }

    updateInspector(data) {
        this.setText("selectedLabel", data.label || "Version")
        this.setText("selectedDate", data.date || "Date unavailable")
        this.setText(
            "selectedChanges",
            `${data.changes || 0} changes`
        )
        this.setText(
            "selectedIntensity",
            data.intensityLabel || "Evolution activity"
        )
        this.setText(
            "selectedSummary",
            data.summary || "No change summary has been recorded for this version."
        )
        this.setText(
            "selectedStatus",
            data.statusLabel || "Historical version"
        )
        this.setText(
            "selectedReview",
            data.reviewLabel || "Needs review"
        )

        if (this.hasInspectorTarget) {
            this.inspectorTarget.classList.remove(
                "animate-[pulse_300ms_ease-out]"
            )

            requestAnimationFrame(() => {
                this.inspectorTarget.classList.add(
                    "animate-[pulse_300ms_ease-out]"
                )
            })
        }

        if (this.hasCompareButtonTarget) {
            const url = data.compareUrl

            if (url) {
                this.compareButtonTarget.href = url
                this.compareButtonTarget.removeAttribute("aria-disabled")
                this.compareButtonTarget.classList.remove(
                    "pointer-events-none",
                    "opacity-50"
                )
            } else {
                this.compareButtonTarget.removeAttribute("href")
                this.compareButtonTarget.setAttribute("aria-disabled", "true")
                this.compareButtonTarget.classList.add(
                    "pointer-events-none",
                    "opacity-50"
                )
            }
        }
    }

    updateNavigation() {
        if (this.hasPreviousButtonTarget) {
            this.previousButtonTarget.disabled = this.currentIndex <= 0
        }

        if (this.hasNextButtonTarget) {
            this.nextButtonTarget.disabled =
                this.currentIndex >= this.nodeTargets.length - 1
        }

        if (this.hasPositionTarget) {
            this.positionTarget.textContent =
                `${this.currentIndex + 1} / ${this.nodeTargets.length}`
        }
    }

    updateProgress() {
        if (!this.hasProgressTarget) return

        const total = this.nodeTargets.length

        if (total <= 1) {
            this.progressTarget.style.width = "100%"
            return
        }

        const percentage =
            (this.currentIndex / (total - 1)) * 100

        this.progressTarget.style.width = `${percentage}%`
    }

    scrollNodeIntoView(node) {
        if (!node) return

        const container = this.element.querySelector(
            "[data-version-evolution-scroll]"
        )

        if (!container) return

        const nodeLeft = node.offsetLeft
        const nodeWidth = node.offsetWidth
        const containerWidth = container.clientWidth

        const target =
            nodeLeft -
            (containerWidth / 2) +
            (nodeWidth / 2)

        container.scrollTo({
            left: Math.max(0, target),
            behavior: "smooth"
        })
    }

    setText(targetName, value) {
        const target = `${targetName}Target`

        if (!this[`has${targetName.charAt(0).toUpperCase()}${targetName.slice(1)}Target`]) {
            return
        }

        this[target].textContent = value
    }

    announce(message) {
        if (!this.hasLiveRegionTarget) return

        this.liveRegionTarget.textContent = ""

        requestAnimationFrame(() => {
            this.liveRegionTarget.textContent = message
        })
    }
}