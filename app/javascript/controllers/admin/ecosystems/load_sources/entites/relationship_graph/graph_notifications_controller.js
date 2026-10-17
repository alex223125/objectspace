
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["container"];

    static values = {
        duration: { type: Number, default: 5000 },
        maxItems: { type: Number, default: 4 }
    };

    connect() {
        this.notifications = [];
        this.nextId = 1;
    }

    disconnect() {
        this.notifications.forEach((notification) => {
            clearTimeout(notification.timer);
        });
    }

    success(event) {
        this.show(event.detail?.message || "Operation completed.", "success");
    }

    warning(event) {
        this.show(event.detail?.message || "Please review this operation.", "warning");
    }

    error(event) {
        this.show(event.detail?.message || "Something went wrong.", "error");
    }

    info(event) {
        this.show(event.detail?.message || "Graph updated.", "info");
    }

    show(message, type = "info") {
        if (!this.hasContainerTarget) return;

        const id = this.nextId++;
        const item = document.createElement("div");

        item.className =
            "flex items-start gap-3 rounded-2xl border-2 p-4 shadow-lg " +
            this.styleFor(type);

        item.setAttribute("role", type === "error" ? "alert" : "status");

        const content = document.createElement("p");
        content.className = "min-w-0 flex-1 text-sm font-semibold leading-6";
        content.textContent = String(message);

        const close = document.createElement("button");
        close.type = "button";
        close.className =
            "shrink-0 rounded-lg px-2 py-1 text-sm font-black " +
            "hover:bg-black/5 focus:outline-none focus:ring-2 focus:ring-orange-400";
        close.textContent = "×";
        close.setAttribute("aria-label", "Dismiss notification");
        close.addEventListener("click", () => this.dismiss(id));

        item.append(content, close);
        this.containerTarget.prepend(item);

        const notification = {
            id,
            element: item,
            timer: null
        };

        this.notifications.push(notification);

        const max = Math.max(1, this.maxItemsValue);

        while (this.notifications.length > max) {
            this.remove(this.notifications[0]);
        }

        if (this.durationValue > 0) {
            notification.timer = setTimeout(
                () => this.dismiss(id),
                this.durationValue
            );
        }
    }

    dismiss(id) {
        const notification = this.notifications.find((item) => item.id === id);

        if (notification) this.remove(notification);
    }

    remove(notification) {
        clearTimeout(notification.timer);
        notification.element.remove();

        this.notifications = this.notifications.filter(
            (item) => item.id !== notification.id
        );
    }

    styleFor(type) {
        const classes = {
            success:
                "border-emerald-200 bg-emerald-50 text-emerald-900",
            warning:
                "border-amber-200 bg-amber-50 text-amber-950",
            error:
                "border-rose-200 bg-rose-50 text-rose-950",
            info:
                "border-sky-200 bg-sky-50 text-sky-950"
        };

        return classes[type] || classes.info;
    }
}