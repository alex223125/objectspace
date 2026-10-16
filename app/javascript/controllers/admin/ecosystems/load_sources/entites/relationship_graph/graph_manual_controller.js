
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("[graph-manual] Connected", this.element);
  }

  disconnect() {
    console.log("[graph-manual] Disconnected");
  }

  open(event) {
    console.group("[graph-manual] open()");
    console.log("Triggered by:", event?.currentTarget);

    try {
      const manual = this.findManual();

      if (manual) {
        manual.scrollIntoView({
          behavior: "smooth",
          block: "start"
        });

        if (manual.matches("details")) {
          manual.open = true;
        }

        console.log("[graph-manual] Manual located:", manual);
      } else {
        console.warn(
            "[graph-manual] Manual not found. Add id='graph-field-manual' " +
            "to the manual section or data-graph-manual-target='manual'."
        );
      }
    } catch (error) {
      console.error("[graph-manual] open() failed:", error);
    } finally {
      console.groupEnd();
    }
  }

  toggleAll(event) {
    console.group("[graph-manual] toggleAll()");

    try {
      const details = Array.from(
          this.element.querySelectorAll("details")
      );

      if (details.length === 0) {
        console.warn("[graph-manual] No details elements found.");
        return;
      }

      const shouldOpen = details.some((item) => !item.open);

      details.forEach((item) => {
        item.open = shouldOpen;
      });

      console.log("[graph-manual] Chapters:", details.length);
      console.log("[graph-manual] All chapters open:", shouldOpen);
    } catch (error) {
      console.error("[graph-manual] toggleAll() failed:", error);
    } finally {
      console.groupEnd();
    }
  }

  closeDialog(event) {
    console.log("[graph-manual] closeDialog()", event?.currentTarget);

    const dialog = this.findDialog();

    if (!dialog) {
      console.warn(
          "[graph-manual] No dialog found. Check the confirmation_dialog partial."
      );
      return;
    }

    if (dialog instanceof HTMLDialogElement && dialog.open) {
      dialog.close();
    } else {
      dialog.hidden = true;
      dialog.setAttribute("aria-hidden", "true");
    }

    console.log("[graph-manual] Dialog closed.");
  }

  confirmAction(event) {
    console.warn(
        "[graph-manual] confirmAction() called, but no business action is configured.",
        event?.currentTarget
    );

    const dialog = this.findDialog();

    if (dialog) {
      dialog.dispatchEvent(
          new CustomEvent("graph-manual:confirm", {
            bubbles: true,
            detail: { confirmed: true }
          })
      );

      console.log(
          "[graph-manual] Confirmation event dispatched. " +
          "No database changes were performed by this controller."
      );
    } else {
      console.warn("[graph-manual] No confirmation dialog found.");
    }
  }

  findManual() {
    return (
        this.element.querySelector(
            "[data-graph-manual-target='manual']"
        ) ||
        document.getElementById("graph-field-manual") ||
        document.getElementById("field-manual")
    );
  }

  findDialog() {
    return (
        this.element.querySelector(
            "[data-graph-manual-target='dialog']"
        ) ||
        document.getElementById("graph-confirmation-dialog") ||
        this.element.querySelector("dialog")
    );
  }
}