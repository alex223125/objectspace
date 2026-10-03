import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.observer = new MutationObserver(
            this.handleMutation.bind(this)
        )

        this.observer.observe(
            this.element,
            {
                childList: true,
                subtree: true
            }
        )

        this.cooldown = null
    }

    disconnect() {
        if (this.observer) {
            this.observer.disconnect()
        }

        if (this.cooldown) {
            clearTimeout(this.cooldown)
        }
    }

    handleMutation() {
        if (this.cooldown) {
            return
        }

        this.cooldown = setTimeout(() => {
            this.cooldown = null

            this.dispatch(
                "updated",
                {
                    prefix: "entity-comparison"
                }
            )
        }, 150)
    }
}