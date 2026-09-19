import { describe, expect, it } from "vitest"
import {
    parseDefinition,
    repairDefinition,
    validateDefinition
} from "../../app/javascript/definition_repair"

describe("Definition Repair Engine", () => {
    describe("valid JSON", () => {
        it("accepts a valid definition", () => {
            const json = JSON.stringify({
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

            const parsed = parseDefinition(json)

            expect(parsed.success).toBe(true)
            expect(parsed.value.fields).toHaveLength(1)
            expect(parsed.value.fields[0].name).toBe("product_name")
        })
    })

    describe("invalid JSON syntax", () => {
        it("reports malformed JSON", () => {
            const result = parseDefinition(`{
        "fields": [
          {"name": "product_name"
        ]
      }`)

            expect(result.success).toBe(false)
            expect(result.error).toBeTruthy()
        })
    })

    describe("field name normalization", () => {
        it("repairs spaces", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "Product Name",
                        label: "Product Name",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields[0].name).toBe("product_name")
        })

        it("repairs repeated spaces", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "Product  Name",
                        label: "Product Name",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields[0].name).toBe("product_name")
        })

        it("repairs hyphens", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "product-name",
                        label: "Product Name",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields[0].name).toBe("product_name")
        })

        it("repairs dots", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "Product.Name",
                        label: "Product Name",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields[0].name).toBe("product_name")
        })

        it("handles names beginning with numbers", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "123 Product",
                        label: "123 Product",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields[0].name).toBe("field_123_product")
        })

        it("does not modify an already-valid name", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "product_name",
                        label: "Product Name",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields[0].name).toBe("product_name")
            expect(result.changes).toHaveLength(0)
        })
    })

    describe("duplicate names", () => {
        it("creates deterministic suffixes", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "product_name",
                        label: "Product Name",
                        type: "string"
                    },
                    {
                        name: "product_name",
                        label: "Product Name 2",
                        type: "string"
                    },
                    {
                        name: "product_name",
                        label: "Product Name 3",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields.map((field) => field.name)).toEqual([
                "product_name",
                "product_name_2",
                "product_name_3"
            ])
        })

        it("handles duplicates created after normalization", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "Product Name",
                        label: "Product Name",
                        type: "string"
                    },
                    {
                        name: "product-name",
                        label: "Product Name",
                        type: "string"
                    },
                    {
                        name: "Product.Name",
                        label: "Product Name",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields.map((field) => field.name)).toEqual([
                "product_name",
                "product_name_2",
                "product_name_3"
            ])
        })

        it("does not overwrite a valid first occurrence", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "product_name",
                        label: "Product Name",
                        type: "string"
                    },
                    {
                        name: "product_name",
                        label: "Another Product Name",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields[0].name).toBe("product_name")
            expect(result.repaired.fields[1].name).toBe("product_name_2")
        })
    })

    describe("empty names", () => {
        it("creates a deterministic name for an empty field name", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "",
                        label: "Product Name",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields[0].name).toBe("product_name")
        })

        it("uses a generated field name when both name and label are empty", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "",
                        label: "",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields[0].name).toBe("field_1")
        })

        it("generates unique names for multiple empty fields", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "",
                        label: "",
                        type: "string"
                    },
                    {
                        name: "",
                        label: "",
                        type: "string"
                    },
                    {
                        name: "",
                        label: "",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields.map((field) => field.name)).toEqual([
                "field_1",
                "field_2",
                "field_3"
            ])
        })
    })

    describe("labels", () => {
        it("preserves existing labels", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "Product Name",
                        label: "My Custom Product Label",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields[0].name).toBe("product_name")
            expect(result.repaired.fields[0].label).toBe(
                "My Custom Product Label"
            )
        })

        it("creates a label when the label is missing", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "product_name",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields[0].label).toBe("Product Name")
        })
    })

    describe("unsupported field types", () => {
        it("normalizes unsupported types to string", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "product_name",
                        label: "Product Name",
                        type: "unsupported_type"
                    }
                ]
            })

            expect(result.repaired.fields[0].type).toBe("string")

            expect(
                result.changes.some(
                    (change) =>
                        change.field === "product_name" &&
                        change.repairedValue === "string"
                )
            ).toBe(true)
        })

        it("supports the builder field types", () => {
            const types = [
                "string",
                "text",
                "integer",
                "number",
                "boolean",
                "date",
                "datetime",
                "email",
                "url",
                "json"
            ]

            const result = repairDefinition({
                fields: types.map((type, index) => ({
                    name: `field_${index + 1}`,
                    label: `Field ${index + 1}`,
                    type
                }))
            })

            expect(result.repaired.fields.map((field) => field.type)).toEqual(types)
        })
    })

    describe("boolean normalization", () => {
        it("normalizes string true", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "active",
                        label: "Active",
                        type: "string",
                        required: "true",
                        multiple: "false",
                        active: "true"
                    }
                ]
            })

            expect(result.repaired.fields[0].required).toBe(true)
            expect(result.repaired.fields[0].multiple).toBe(false)
            expect(result.repaired.fields[0].active).toBe(true)
        })

        it("normalizes numeric booleans", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "active",
                        label: "Active",
                        type: "string",
                        required: 1,
                        multiple: 0,
                        active: 1
                    }
                ]
            })

            expect(result.repaired.fields[0].required).toBe(true)
            expect(result.repaired.fields[0].multiple).toBe(false)
            expect(result.repaired.fields[0].active).toBe(true)
        })
    })

    describe("missing properties", () => {
        it("adds missing field properties", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "product_name",
                        type: "string"
                    }
                ]
            })

            expect(result.repaired.fields[0]).toMatchObject({
                name: "product_name",
                label: "Product Name",
                type: "string",
                required: false,
                multiple: false,
                active: true
            })
        })

        it("does not overwrite explicitly provided values", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "product_name",
                        label: "Custom Label",
                        type: "string",
                        required: true,
                        multiple: true,
                        active: false
                    }
                ]
            })

            expect(result.repaired.fields[0]).toMatchObject({
                name: "product_name",
                label: "Custom Label",
                type: "string",
                required: true,
                multiple: true,
                active: false
            })
        })
    })

    describe("malformed field structures", () => {
        it("repairs a field represented as a string", () => {
            const result = repairDefinition({
                fields: [
                    "Product Name"
                ]
            })

            expect(result.repaired.fields[0]).toMatchObject({
                name: "product_name",
                label: "Product Name",
                type: "string",
                required: false,
                multiple: false,
                active: true
            })
        })

        it("repairs a null field conservatively", () => {
            const result = repairDefinition({
                fields: [
                    null
                ]
            })

            expect(result.repaired.fields[0].name).toBe("field_1")
            expect(result.repaired.fields[0].type).toBe("string")
        })
    })

    describe("multiple fields", () => {
        it("repairs all fields while preserving order", () => {
            const result = repairDefinition({
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
                        label: "Another Product",
                        type: "number"
                    }
                ]
            })

            expect(result.repaired.fields.map((field) => field.name)).toEqual([
                "product_name",
                "stock_quantity",
                "product_name_2"
            ])

            expect(result.repaired.fields.map((field) => field.type)).toEqual([
                "string",
                "integer",
                "number"
            ])
        })
    })

    describe("change log", () => {
        it("records field, original value, repaired value and reason", () => {
            const result = repairDefinition({
                fields: [
                    {
                        name: "Product Name",
                        label: "Product Name",
                        type: "string"
                    }
                ]
            })

            expect(result.changes.length).toBeGreaterThan(0)

            const nameChange = result.changes.find(
                (change) => change.field === "Product Name"
            )

            expect(nameChange).toBeTruthy()
            expect(nameChange.originalValue).toBe("Product Name")
            expect(nameChange.repairedValue).toBe("product_name")
            expect(nameChange.reason).toBeTruthy()
        })

        it("does not create changes for an already-valid definition", () => {
            const result = repairDefinition({
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
            })

            expect(result.changes).toHaveLength(0)
            expect(result.changed).toBe(false)
        })
    })

    describe("validation after repair", () => {
        it("validates the repaired definition", () => {
            const result = repairDefinition({
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
                    }
                ]
            })

            const validation = validateDefinition(result.repaired)

            expect(validation.valid).toBe(true)
            expect(validation.errors).toEqual([])
        })

        it("reports an invalid fields container", () => {
            const validation = validateDefinition({
                fields: "not-an-array"
            })

            expect(validation.valid).toBe(false)
            expect(validation.errors.length).toBeGreaterThan(0)
        })
    })
})