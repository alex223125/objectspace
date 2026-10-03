// frozen_string_literal: true

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "value",
        "bar"
    ]

    static values = {
        score: {
            type: Number,
            default: 0
        }
    }

    connect() {
        this.animate()
    }

    animate() {
        const target = Math.max(
            0,
            Math.min(100, this.scoreValue)
        )

        if (this.hasBarTarget) {
            this.barTarget.style.transform = "scaleX(0)"

            requestAnimationFrame(() => {
                this.barTarget.style.transition =
                    "transform 900ms cubic-bezier(.2,.8,.2,1)"

                this.barTarget.style.transform =
                    `scaleX(${target / 100})`
            })
        }

        if (!this.hasValueTarget) {
            return
        }

        const start = 0
        const duration = 900
        const startedAt = performance.now()

        const frame = (now) => {
            const progress = Math.min(
                (now - startedAt) / duration,
                1
            )

            const eased =
                1 - Math.pow(1 - progress, 3)

            const current =
                Math.round(
                    start +
                    (target - start) * eased
                )

            this.valueTarget.textContent = current

            if (progress < 1) {
                requestAnimationFrame(frame)
            }
        }

        requestAnimationFrame(frame)
    }
}