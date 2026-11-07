
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["chart", "bar", "summary", "mode"]

    connect() {
        this.render()
    }

    render() {
        const bars = this.barTargets.map(bar => ({
            element: bar,
            label: bar.dataset.chartLabel || "Unlabelled",
            value: Number(bar.dataset.chartValue)
        })).filter(item => Number.isFinite(item.value) && item.value >= 0)

        const max = Math.max(1, ...bars.map(item => item.value))

        bars.forEach(({ element, value, label }) => {
            const percentage = Math.max(0, Math.min(100, value / max * 100))

            element.style.setProperty("--chart-bar-width", `${percentage}%`)
            element.style.width = `${percentage}%`
            element.setAttribute("role", "img")
            element.setAttribute("aria-label", `${label}: ${value}`)
            element.title = `${label}: ${value}`
        })

        if (this.hasSummaryTarget) {
            this.summaryTarget.textContent = bars.length
                ? `Chart displays ${bars.length} categories. Highest value: ${max}.`
                : "No chart data is available."
        }
    }

    changeMode(event) {
        if (!this.hasChartTarget) return

        const mode = event.currentTarget.value
        const allowed = ["bar", "compact"]

        if (!allowed.includes(mode)) return

        this.chartTarget.dataset.chartMode = mode
        this.chartTarget.classList.toggle("chart--compact", mode === "compact")

        if (this.hasModeTarget) {
            this.modeTarget.textContent =
                mode === "compact" ? "Compact view" : "Full-size chart"
        }
    }
}