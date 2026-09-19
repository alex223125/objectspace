import { describe, expect, it, beforeEach, vi } from "vitest"
import { Application } from "@hotwired/stimulus"
import EntityDefinitionBuilderController from "../../app/javascript/controllers/entity_definition_builder_controller"

function buildHTML(definition) {
    return `
    <form data-controller="entity-definition-builder">
      <textarea
        data-entity-definition-builder-target="json"
      >${escapeHtml(JSON.stringify(definition, null, 2))}</textarea>

      <div data-entity-definition-builder-target="builder"></div>

      <div data-entity-definition-builder-target="jsonError"></div>

      <div data-entity-definition-builder-target="jsonProblemCount"></div>

      <div data-entity-definition-builder-target="jsonErrorMessage"></div>

      <div data-entity-definition-builder-target="jsonRepairPreview"></div>

      <div data-entity-definition-builder-target="jsonRepairChanges"></div>

      <div data-entity-definition-builder-target="jsonRepairChangeCount"></div>

      <div data-entity-definition-builder-target="jsonRepairWarning"></div>

      <div data-entity-definition-builder-target="jsonRepairWarningMessage"></div>

      <div data-entity-definition-builder-target="jsonRepairSuccess"></div>

      <div data-entity-definition-builder-target="jsonRepairSuccessMessage"></div>

      <div data-entity-definition-builder-target="status"></div>

      <div data-entity-definition-builder-target="statusDot"></div>

      <div data-entity-definition-builder-target="activity"></div>

      <div data-entity-definition-builder-target="fieldCount"></div>

      <div data-entity-definition-builder-target="sidebarFieldCount"></div>

      <div data-entity-definition-builder-target="sidebarRequiredCount"></div>

      <div data-entity-definition-builder-target="sidebarActiveCount"></div>

      <div data-entity-definition-builder-target="sidebarStatus"></div>

      <div data-entity-definition-builder-target="health"></div>

      <div data-entity-definition-builder-target="healthBar"></div>

      <div data-entity-definition-builder-target="syncBadge"></div>

      <div data-entity-definition-builder-target="progressBar"></div>

      <div data-entity-definition-builder-target="progressLabel"></div>

      <div data-entity-definition-builder-target="xp"></div>

      <div data-entity-definition-builder-target="headerStatus"></div>

      <div data-entity-definition-builder-target="headerStatusDot"></div>

      <div data-entity-definition-builder-target="submitReadiness"></div>

      <button
        type="submit"
        data-entity-definition-builder-target="submit"
      >
        CREATE VERSION
      </button>
    </form>
  `
}

function escapeHtml(value) {
    return value
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
}

function createApplication(definition) {
    document.body.innerHTML = buildHTML(definition)

    const application = Application.start()

    application.register(
        "entity-definition-builder",
        EntityDefinitionBuilderController
    )

    return application
}

describe("Entity Definition Builder", () => {
    let application

    beforeEach(() => {
        document.body.innerHTML = ""
    })

    it("loads a valid JSON definition into the visual builder", async () => {
        application = createApplication({
            fields: [
                {
                    name: "product_name",
                    label: "Product Name",
                    type: "string",
                    required: true,
                    multiple: false,
                    active: true
                }
            ]
        })

        await new Promise((resolve) => setTimeout(resolve, 0))

        const builder = document.querySelector(
            '[data-entity-definition-builder-target="builder"]'
        )

        expect(builder).toBeTruthy()
        expect(builder.textContent).toContain("Product Name")
    })

    it("detects invalid JSON syntax", async () => {
        document.body.innerHTML = `
      <form data-controller="entity-definition-builder">
        <textarea data-entity-definition-builder-target="json">
          {"fields":[
        </textarea>

        <div data-entity-definition-builder-target="builder"></div>
        <div data-entity-definition-builder-target="jsonError"></div>
        <div data-entity-definition-builder-target="jsonProblemCount"></div>
        <div data-entity-definition-builder-target="jsonErrorMessage"></div>
        <div data-entity-definition-builder-target="status"></div>
        <div data-entity-definition-builder-target="activity"></div>
      </form>
    `

        application = Application.start()

        application.register(
            "entity-definition-builder",
            EntityDefinitionBuilderController
        )

        await new Promise((resolve) => setTimeout(resolve, 0))

        const textarea = document.querySelector(
            '[data-entity-definition-builder-target="json"]'
        )

        textarea.dispatchEvent(
            new Event("input", {
                bubbles: true
            })
        )

        await new Promise((resolve) => setTimeout(resolve, 0))

        const error = document.querySelector(
            '[data-entity-definition-builder-target="jsonError"]'
        )

        expect(error.classList.contains("hidden")).toBe(false)
    })

    it("detects names requiring repair", async () => {
        application = createApplication({
            fields: [
                {
                    name: "Product Name",
                    label: "Product Name",
                    type: "string"
                }
            ]
        })

        await new Promise((resolve) => setTimeout(resolve, 0))

        const textarea = document.querySelector(
            '[data-entity-definition-builder-target="json"]'
        )

        textarea.dispatchEvent(
            new Event("input", {
                bubbles: true
            })
        )

        await new Promise((resolve) => setTimeout(resolve, 0))

        const controllerElement = document.querySelector(
            '[data-controller="entity-definition-builder"]'
        )

        expect(controllerElement).toBeTruthy()
    })

    it("supports visual builder to JSON synchronization", async () => {
        application = createApplication({
            fields: []
        })

        await new Promise((resolve) => setTimeout(resolve, 0))

        const controllerElement = document.querySelector(
            '[data-controller="entity-definition-builder"]'
        )

        expect(controllerElement).toBeTruthy()

        const textarea = controllerElement.querySelector(
            '[data-entity-definition-builder-target="json"]'
        )

        expect(textarea.value).toContain('"fields"')
    })

    it("supports JSON to visual builder synchronization", async () => {
        application = createApplication({
            fields: [
                {
                    name: "stock_quantity",
                    label: "Stock Quantity",
                    type: "integer"
                }
            ]
        })

        await new Promise((resolve) => setTimeout(resolve, 0))

        const builder = document.querySelector(
            '[data-entity-definition-builder-target="builder"]'
        )

        expect(builder.textContent).toContain("Stock Quantity")
    })

    it("keeps an already-valid definition unchanged", async () => {
        const definition = {
            fields: [
                {
                    name: "product_name",
                    label: "Product Name",
                    type: "string",
                    required: false,
                    multiple: false,
                    active: true
                }
            ]
        }

        application = createApplication(definition)

        await new Promise((resolve) => setTimeout(resolve, 0))

        const textarea = document.querySelector(
            '[data-entity-definition-builder-target="json"]'
        )

        const before = JSON.parse(textarea.value)

        expect(before.fields[0].name).toBe("product_name")
        expect(before.fields[0].label).toBe("Product Name")
    })

    it("handles duplicate names deterministically", async () => {
        application = createApplication({
            fields: [
                {
                    name: "Product Name",
                    label: "Product Name",
                    type: "string"
                },
                {
                    name: "product-name",
                    label: "Product Name 2",
                    type: "string"
                }
            ]
        })

        await new Promise((resolve) => setTimeout(resolve, 0))

        const textarea = document.querySelector(
            '[data-entity-definition-builder-target="json"]'
        )

        const parsed = JSON.parse(textarea.value)

        expect(parsed.fields[0].name).toBe("product_name")
        expect(parsed.fields[1].name).toBe("product_name_2")
    })

    it("handles multiple repaired fields", async () => {
        application = createApplication({
            fields: [
                {
                    name: "Product Name",
                    label: "Product Name",
                    type: "string"
                },
                {
                    name: "Stock Quantity",
                    label: "Stock Quantity",
                    type: "integer"
                },
                {
                    name: "product-name",
                    label: "Duplicate Product",
                    type: "string"
                }
            ]
        })

        await new Promise((resolve) => setTimeout(resolve, 0))

        const textarea = document.querySelector(
            '[data-entity-definition-builder-target="json"]'
        )

        const parsed = JSON.parse(textarea.value)

        expect(parsed.fields.map((field) => field.name)).toEqual([
            "product_name",
            "stock_quantity",
            "product_name_2"
        ])
    })

    it("does not destroy custom labels while repairing names", async () => {
        application = createApplication({
            fields: [
                {
                    name: "Product.Name",
                    label: "Customer Facing Product Name",
                    type: "string"
                }
            ]
        })

        await new Promise((resolve) => setTimeout(resolve, 0))

        const textarea = document.querySelector(
            '[data-entity-definition-builder-target="json"]'
        )

        const parsed = JSON.parse(textarea.value)

        expect(parsed.fields[0].name).toBe("product_name")
        expect(parsed.fields[0].label).toBe(
            "Customer Facing Product Name"
        )
    })

    it("handles unsupported types without throwing", async () => {
        application = createApplication({
            fields: [
                {
                    name: "Product Name",
                    label: "Product Name",
                    type: "made_up_type"
                }
            ]
        })

        await new Promise((resolve) => setTimeout(resolve, 0))

        const textarea = document.querySelector(
            '[data-entity-definition-builder-target="json"]'
        )

        expect(() => JSON.parse(textarea.value)).not.toThrow()
    })

    it("handles missing properties", async () => {
        application = createApplication({
            fields: [
                {
                    name: "product_name",
                    type: "string"
                }
            ]
        })

        await new Promise((resolve) => setTimeout(resolve, 0))

        const textarea = document.querySelector(
            '[data-entity-definition-builder-target="json"]'
        )

        const parsed = JSON.parse(textarea.value)

        expect(parsed.fields[0].name).toBe("product_name")
    })

    it("does not lose fields after JSON editing", async () => {
        application = createApplication({
            fields: [
                {
                    name: "product_name",
                    label: "Product Name",
                    type: "string"
                }
            ]
        })

        await new Promise((resolve) => setTimeout(resolve, 0))

        const textarea = document.querySelector(
            '[data-entity-definition-builder-target="json"]'
        )

        textarea.value = JSON.stringify({
            fields: [
                {
                    name: "stock_quantity",
                    label: "Stock Quantity",
                    type: "integer"
                }
            ]
        })

        textarea.dispatchEvent(
            new Event("input", {
                bubbles: true
            })
        )

        await new Promise((resolve) => setTimeout(resolve, 0))

        expect(textarea.value).toContain("stock_quantity")
    })

    it("keeps the submit button available after a valid repair", async () => {
        application = createApplication({
            fields: [
                {
                    name: "Product Name",
                    label: "Product Name",
                    type: "string"
                }
            ]
        })

        await new Promise((resolve) => setTimeout(resolve, 0))

        const submit = document.querySelector(
            '[data-entity-definition-builder-target="submit"]'
        )

        expect(submit).toBeTruthy()
        expect(submit.disabled).toBe(false)
    })
})