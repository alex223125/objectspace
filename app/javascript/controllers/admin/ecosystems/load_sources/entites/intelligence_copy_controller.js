
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["payload", "status"];

    async copy() {
        if (!this.hasPayloadTarget) {
            this.setStatus("The JSON payload could not be found.");
            return;
        }

        const text = this.payloadTarget.textContent || "";

        try {
            if (navigator.clipboard && window.isSecureContext) {
                await navigator.clipboard.writeText(text);
            } else {
                this.copyUsingFallback(text);
            }

            this.setStatus("JSON copied to clipboard.");
        } catch (_error) {
            this.setStatus(
                "Automatic copying failed. Select the JSON text and copy it manually."
            );
        }
    }

    copyUsingFallback(text) {
        const textarea = document.createElement("textarea");

        textarea.value = text;
        textarea.setAttribute("readonly", "");
        textarea.style.position = "fixed";
        textarea.style.left = "-9999px";
        textarea.style.top = "0";

        this.element.appendChild(textarea);
        textarea.select();

        let copied = false;

        try {
            copied = document.execCommand("copy");
        } finally {
            textarea.remove();
        }

        if (!copied) {
            throw new Error("Clipboard copy failed.");
        }
    }

    setStatus(message) {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent = message;
        }
    }
}