
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["panel", "toggle", "icon"];

    static values = {
        open: {
            type: Boolean,
            default: true,
        },
    };

    connect() {
        this.render();

        // Deliberately do not modify body overflow, page position,
        // document height, or global scrolling.
    }

    disconnect() {
        // No global scroll locks or document-level handlers to clean up.
    }

    toggle(event) {
        event?.preventDefault();

        this.openValue = !this.openValue;
    }

    open() {
        this.openValue = true;
    }

    close() {
        this.openValue = false;
    }

    openValueChanged() {
        this.render();
    }

    render() {
        if (!this.hasPanelTarget) return;

        this.panelTarget.hidden = !this.openValue;

        if (this.hasToggleTarget) {
            this.toggleTarget.setAttribute(
                "aria-expanded",
                String(this.openValue)
            );
        }

        if (this.hasIconTarget) {
            this.iconTarget.textContent = this.openValue ? "−" : "+";

            this.iconTarget.classList.toggle(
                "rotate-180",
                !this.openValue
            );
        }
    }
}