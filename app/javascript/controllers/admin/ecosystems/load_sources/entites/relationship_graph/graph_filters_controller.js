
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  apply(event) {
    const form = event?.currentTarget?.closest("form") ||
        this.element.querySelector("form")

    if (form) {
      form.requestSubmit()
      return
    }

    const filterForm = this.element.closest("form")
    if (filterForm) filterForm.requestSubmit()
  }
}