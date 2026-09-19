/**
 * JSON Definition Repair Engine
 *
 * This module intentionally contains NO Stimulus-specific code.
 *
 * Responsibilities:
 * - Parse JSON
 * - Validate/normalize entity-definition structures
 * - Normalize field names
 * - Preserve human-readable labels
 * - Repair duplicate names
 * - Repair empty names
 * - Normalize unsupported field types
 * - Normalize booleans
 * - Add missing properties
 * - Safely normalize malformed field structures
 * - Generate a detailed change log
 * - Detect potentially destructive changes
 *
 * The original input is never mutated.
 */

const DEFAULT_FIELD_TYPE = "string";

const SUPPORTED_FIELD_TYPES = [
  "string",
  "text",
  "integer",
  "number",
  "boolean",
  "date",
  "datetime",
  "email",
  "url",
  "json",
];

const DEFAULT_FIELD = {
  description: "",
  required: false,
  multiple: false,
  active: true,
};

const IDENTIFIER_PATTERN = /^[A-Za-z_][A-Za-z0-9_]*$/;

const RESERVED_NAMES = new Set([
  "__proto__",
  "prototype",
  "constructor",
]);

/**
 * Public API
 */
export class JsonDefinitionRepair {
  constructor(options = {}) {
    this.options = {
      defaultFieldType: options.defaultFieldType || DEFAULT_FIELD_TYPE,
      supportedTypes: options.supportedTypes || SUPPORTED_FIELD_TYPES,
      preserveCase: options.preserveCase ?? false,
      ...options,
    };
  }

  /**
   * Analyze JSON without applying anything.
   *
   * Returns:
   * {
   *   validJson,
   *   validDefinition,
   *   originalValue,
   *   repairedValue,
   *   changes,
   *   problems,
   *   warnings,
   *   destructive,
   *   canRepair
   * }
   */
  analyze(input) {
    const originalValue = String(input ?? "");

    const parsed = this.parseJson(originalValue);

    if (!parsed.success) {
      return {
        validJson: false,
        validDefinition: false,
        originalValue,
        repairedValue: null,
        changes: [],
        problems: [
          {
            code: "invalid_json",
            path: "",
            field: "JSON",
            message: parsed.error,
            explanation:
              "The editor contains invalid JSON, so the definition cannot be repaired until the JSON structure can be parsed.",
          },
        ],
        warnings: [],
        destructive: false,
        canRepair: false,
        error: parsed.error,
      };
    }

    const result = this.repairDefinition(parsed.value);

    return {
      validJson: true,
      validDefinition: result.problems.length === 0,
      originalValue,
      repairedValue: result.value,
      changes: result.changes,
      problems: result.problems,
      warnings: result.warnings,
      destructive: result.destructive,
      canRepair: result.changes.length > 0 || result.problems.length === 0,
      error: null,
    };
  }

  /**
   * Repair JSON.
   *
   * Returns a pretty JSON string plus metadata.
   */
  repair(input) {
    const analysis = this.analyze(input);

    if (!analysis.validJson) {
      return {
        success: false,
        json: null,
        ...analysis,
      };
    }

    const json = JSON.stringify(analysis.repairedValue, null, 2);

    return {
      success: analysis.problems.length === 0,
      json,
      ...analysis,
    };
  }

  /**
   * Format valid JSON only.
   *
   * IMPORTANT:
   * This never performs semantic repair.
   */
  formatOnly(input) {
    const parsed = this.parseJson(String(input ?? ""));

    if (!parsed.success) {
      return {
        success: false,
        json: null,
        error: parsed.error,
      };
    }

    return {
      success: true,
      json: JSON.stringify(parsed.value, null, 2),
      value: parsed.value,
    };
  }

  parseJson(input) {
    try {
      return {
        success: true,
        value: JSON.parse(input),
        error: null,
      };
    } catch (error) {
      return {
        success: false,
        value: null,
        error: this.humanizeJsonParseError(error),
      };
    }
  }

  /**
   * ------------------------------------------------------------
   * Definition repair
   * ------------------------------------------------------------
   */

  repairDefinition(input) {
    const changes = [];
    const problems = [];
    const warnings = [];

    let value = this.clone(input);

    if (!value || typeof value !== "object" || Array.isArray(value)) {
      problems.push({
        code: "definition_not_object",
        path: "",
        field: "Definition",
        message: "The definition must be a JSON object.",
        explanation:
          'The top-level JSON value should look like { "fields": [] }.',
      });

      return {
        value,
        changes,
        problems,
        warnings,
        destructive: false,
      };
    }

    /**
     * fields missing
     */
    if (!Object.prototype.hasOwnProperty.call(value, "fields")) {
      value.fields = [];

      changes.push(
        this.change({
          path: "fields",
          field: "fields",
          originalValue: undefined,
          repairedValue: [],
          reason: 'Missing "fields" property was added as an empty array.',
          destructive: false,
          category: "missing_property",
        })
      );
    }

    /**
     * fields malformed
     */
    if (!Array.isArray(value.fields)) {
      const original = value.fields;

      const converted = this.tryConvertFields(original);

      if (converted.success) {
        value.fields = converted.fields;

        changes.push(
          this.change({
            path: "fields",
            field: "fields",
            originalValue: original,
            repairedValue: converted.fields,
            reason:
              'The "fields" property was converted into an array because the builder requires fields to be an array.',
            destructive: converted.destructive,
            category: "malformed_structure",
          })
        );

        if (converted.destructive) {
          warnings.push(
            this.warning(
              "fields_conversion",
              "The fields structure was malformed and could not be converted with complete certainty."
            )
          );
        }
      } else {
        problems.push({
          code: "fields_not_array",
          path: "fields",
          field: "fields",
          message: '"fields" must be an array.',
          explanation:
            'The builder expects the definition to contain "fields": [ ... ].',
        });

        return {
          value,
          changes,
          problems,
          warnings,
          destructive: false,
        };
      }
    }

    /**
     * Repair each field.
     */
    const repairedFields = [];

    value.fields.forEach((rawField, index) => {
      const result = this.repairField(rawField, index);

      if (result.value !== null) {
        repairedFields.push(result.value);
      }

      changes.push(...result.changes);
      problems.push(...result.problems);
      warnings.push(...result.warnings);
    });

    value.fields = repairedFields;

    /**
     * Duplicate names must be handled after all names
     * have been normalized.
     */
    const duplicateResult = this.repairDuplicateNames(value.fields);

    value.fields = duplicateResult.fields;

    changes.push(...duplicateResult.changes);
    problems.push(...duplicateResult.problems);
    warnings.push(...duplicateResult.warnings);

    /**
     * Final validation.
     */
    const finalProblems = this.validateDefinition(value);

    problems.push(...finalProblems);

    const destructive =
      changes.some((change) => change.destructive === true) ||
      warnings.length > 0;

    return {
      value,
      changes,
      problems,
      warnings,
      destructive,
    };
  }

  /**
   * ------------------------------------------------------------
   * Field repair
   * ------------------------------------------------------------
   */

  repairField(rawField, index) {
    const path = `fields[${index}]`;

    const changes = [];
    const problems = [];
    const warnings = [];

    /**
     * A field should be an object.
     */
    if (!rawField || typeof rawField !== "object" || Array.isArray(rawField)) {
      const converted = this.convertMalformedField(rawField, index);

      if (!converted.success) {
        problems.push({
          code: "malformed_field",
          path,
          field: `Field ${index + 1}`,
          message: `Field ${index + 1} is not a valid object.`,
          explanation:
            "A field must be represented as an object containing properties such as name, label and type.",
        });

        return {
          value: null,
          changes,
          problems,
          warnings,
        };
      }

      changes.push(
        this.change({
          path,
          field: `Field ${index + 1}`,
          originalValue: rawField,
          repairedValue: converted.field,
          reason:
            "The malformed field was converted into a safe field object.",
          destructive: converted.destructive,
          category: "malformed_structure",
        })
      );

      if (converted.destructive) {
        warnings.push(
          this.warning(
            "malformed_field_conversion",
            `Field ${index + 1} required a structural conversion. Review the repaired value before saving.`
          )
        );
      }

      rawField = converted.field;
    }

    const field = {
      ...this.clone(rawField),
    };

    /**
     * Preserve label before changing name.
     */
    const originalName = field.name;
    const originalLabel = field.label;

    /**
     * Name
     */
    const normalizedName = this.normalizeFieldName(
      field.name,
      field.label,
      index
    );

    if (normalizedName !== field.name) {
      field.name = normalizedName;

      changes.push(
        this.change({
          path: `${path}.name`,
          field: "Field name",
          originalValue: originalName,
          repairedValue: normalizedName,
          reason:
            "Field names must contain only letters, numbers and underscores and must begin with a letter or underscore.",
          destructive: false,
          category: "field_name",
        })
      );
    }

    /**
     * Label
     *
     * Never replace an existing human-readable label just because
     * the field name changed.
     */
    if (
      !Object.prototype.hasOwnProperty.call(field, "label") ||
      field.label === null ||
      String(field.label).trim() === ""
    ) {
      const generatedLabel = this.humanizeFieldName(field.name);

      field.label = generatedLabel;

      changes.push(
        this.change({
          path: `${path}.label`,
          field: "Label",
          originalValue: originalLabel,
          repairedValue: generatedLabel,
          reason:
            "The field had no usable label, so a readable label was generated from the repaired field name.",
          destructive: false,
          category: "missing_property",
        })
      );
    } else if (typeof field.label !== "string") {
      const normalizedLabel = String(field.label);

      field.label = normalizedLabel;

      changes.push(
        this.change({
          path: `${path}.label`,
          field: "Label",
          originalValue: originalLabel,
          repairedValue: normalizedLabel,
          reason: "Labels must be stored as text.",
          destructive: false,
          category: "type_normalization",
        })
      );
    }

    /**
     * Type
     */
    const originalType = field.type;
    const normalizedType = this.normalizeType(field.type);

    if (normalizedType !== field.type) {
      field.type = normalizedType;

      changes.push(
        this.change({
          path: `${path}.type`,
          field: "Type",
          originalValue: originalType,
          repairedValue: normalizedType,
          reason:
            "The field type was missing or unsupported, so it was replaced with the default supported type.",
          destructive: false,
          category: "type_normalization",
        })
      );
    }

    /**
     * Description
     */
    if (!Object.prototype.hasOwnProperty.call(field, "description")) {
      field.description = DEFAULT_FIELD.description;

      changes.push(
        this.change({
          path: `${path}.description`,
          field: "Description",
          originalValue: undefined,
          repairedValue: "",
          reason:
            "Missing description was added so every field has a predictable structure.",
          destructive: false,
          category: "missing_property",
        })
      );
    } else if (field.description === null) {
      field.description = "";

      changes.push(
        this.change({
          path: `${path}.description`,
          field: "Description",
          originalValue: null,
          repairedValue: "",
          reason: "Null descriptions are normalized to an empty string.",
          destructive: false,
          category: "type_normalization",
        })
      );
    } else if (typeof field.description !== "string") {
      const normalizedDescription = String(field.description);

      field.description = normalizedDescription;

      changes.push(
        this.change({
          path: `${path}.description`,
          field: "Description",
          originalValue: field.description,
          repairedValue: normalizedDescription,
          reason: "Descriptions must be stored as text.",
          destructive: false,
          category: "type_normalization",
        })
      );
    }

    /**
     * Required
     */
    const requiredResult = this.normalizeBoolean(
      field.required,
      DEFAULT_FIELD.required
    );

    if (
      !Object.prototype.hasOwnProperty.call(field, "required") ||
      requiredResult.value !== field.required
    ) {
      const original = field.required;

      field.required = requiredResult.value;

      changes.push(
        this.change({
          path: `${path}.required`,
          field: "Required",
          originalValue: original,
          repairedValue: requiredResult.value,
          reason: requiredResult.reason,
          destructive: false,
          category: "boolean_normalization",
        })
      );
    }

    /**
     * Multiple
     */
    const multipleResult = this.normalizeBoolean(
      field.multiple,
      DEFAULT_FIELD.multiple
    );

    if (
      !Object.prototype.hasOwnProperty.call(field, "multiple") ||
      multipleResult.value !== field.multiple
    ) {
      const original = field.multiple;

      field.multiple = multipleResult.value;

      changes.push(
        this.change({
          path: `${path}.multiple`,
          field: "Multiple",
          originalValue: original,
          repairedValue: multipleResult.value,
          reason: multipleResult.reason,
          destructive: false,
          category: "boolean_normalization",
        })
      );
    }

    /**
     * Active
     */
    const activeResult = this.normalizeBoolean(
      field.active,
      DEFAULT_FIELD.active
    );

    if (
      !Object.prototype.hasOwnProperty.call(field, "active") ||
      activeResult.value !== field.active
    ) {
      const original = field.active;

      field.active = activeResult.value;

      changes.push(
        this.change({
          path: `${path}.active`,
          field: "Active",
          originalValue: original,
          repairedValue: activeResult.value,
          reason: activeResult.reason,
          destructive: false,
          category: "boolean_normalization",
        })
      );
    }

    return {
      value: field,
      changes,
      problems,
      warnings,
    };
  }

  /**
   * ------------------------------------------------------------
   * Name normalization
   * ------------------------------------------------------------
   */

  normalizeFieldName(rawName, label, index) {
    let source = rawName;

    if (
      source === null ||
      source === undefined ||
      String(source).trim() === ""
    ) {
      source = label;

      if (
        source === null ||
        source === undefined ||
        String(source).trim() === ""
      ) {
        source = `field_${index + 1}`;
      }
    }

    let name = String(source).trim();

    /**
     * Convert whitespace and separators to underscores.
     *
     * Product Name -> Product_Name
     * product name -> product_name after casing policy
     * product-name -> product_name
     * product.name -> product_name
     */
    name = name.replace(/[\s\-./\\:]+/g, "_");

    /**
     * Remove all characters that are not valid.
     */
    name = name.replace(/[^A-Za-z0-9_]/g, "_");

    /**
     * Collapse repeated underscores.
     */
    name = name.replace(/_+/g, "_");

    /**
     * Remove leading/trailing underscores temporarily.
     */
    name = name.replace(/^_+|_+$/g, "");

    /**
     * If everything disappeared, create a stable name.
     */
    if (!name) {
      name = `field_${index + 1}`;
    }

    /**
     * A field name cannot begin with a number.
     */
    if (/^[0-9]/.test(name)) {
      name = `field_${name}`;
    }

    /**
     * Default behavior converts field identifiers to snake_case.
     *
     * Product Name -> product_name
     * Product-ID -> product_id
     */
    if (!this.options.preserveCase) {
      name = name
        .replace(/([a-z0-9])([A-Z])/g, "$1_$2")
        .toLowerCase();
    }

    /**
     * Reserved JavaScript object names are avoided.
     */
    if (RESERVED_NAMES.has(name)) {
      name = `${name}_field`;
    }

    /**
     * Final safety check.
     */
    if (!IDENTIFIER_PATTERN.test(name)) {
      name = `field_${index + 1}`;
    }

    return name;
  }

  humanizeFieldName(name) {
    return String(name || "")
      .replace(/_/g, " ")
      .replace(/\s+/g, " ")
      .trim()
      .replace(/\b\w/g, (character) => character.toUpperCase());
  }

  /**
   * ------------------------------------------------------------
   * Duplicate names
   * ------------------------------------------------------------
   */

  repairDuplicateNames(fields) {
    const usedNames = new Map();
    const changes = [];
    const problems = [];
    const warnings = [];

    const repairedFields = fields.map((field, index) => {
      const originalName = field.name;
      let name = originalName;

      const count = usedNames.get(name) || 0;

      if (count === 0) {
        usedNames.set(name, 1);
        return field;
      }

      let suffix = count + 1;
      let candidate = `${name}_${suffix}`;

      while (usedNames.has(candidate)) {
        suffix += 1;
        candidate = `${name}_${suffix}`;
      }

      usedNames.set(name, suffix);
      usedNames.set(candidate, 1);

      const repairedField = {
        ...field,
        name: candidate,
      };

      changes.push(
        this.change({
          path: `fields[${index}].name`,
          field: "Field name",
          originalValue: originalName,
          repairedValue: candidate,
          reason:
            "The field name was duplicated, so a numeric suffix was added to make the name unique.",
          destructive: false,
          category: "duplicate_name",
        })
      );

      return repairedField;
    });

    return {
      fields: repairedFields,
      changes,
      problems,
      warnings,
    };
  }

  /**
   * ------------------------------------------------------------
   * Type normalization
   * ------------------------------------------------------------
   */

  normalizeType(type) {
    if (typeof type !== "string") {
      return this.options.defaultFieldType;
    }

    const normalized = type.trim().toLowerCase();

    const aliases = {
      str: "string",
      textfield: "string",
      varchar: "string",
      int: "integer",
      bool: "boolean",
      float: "number",
      double: "number",
      decimal: "number",
      longtext: "text",
      timestamp: "datetime",
      object: "json",
    };

    if (aliases[normalized]) {
      return aliases[normalized];
    }

    if (this.options.supportedTypes.includes(normalized)) {
      return normalized;
    }

    return this.options.defaultFieldType;
  }

  /**
   * ------------------------------------------------------------
   * Boolean normalization
   * ------------------------------------------------------------
   */

  normalizeBoolean(value, fallback) {
    if (value === true) {
      return {
        value: true,
        reason: "Boolean value is already normalized.",
      };
    }

    if (value === false) {
      return {
        value: false,
        reason: "Boolean value is already normalized.",
      };
    }

    if (value === null || value === undefined || value === "") {
      return {
        value: fallback,
        reason: `Missing boolean value was normalized to ${fallback}.`,
      };
    }

    if (typeof value === "number") {
      if (value === 1) {
        return {
          value: true,
          reason: "Numeric boolean value 1 was normalized to true.",
        };
      }

      if (value === 0) {
        return {
          value: false,
          reason: "Numeric boolean value 0 was normalized to false.",
        };
      }
    }

    if (typeof value === "string") {
      const normalized = value.trim().toLowerCase();

      if (["true", "yes", "y", "on", "enabled", "1"].includes(normalized)) {
        return {
          value: true,
          reason: `"${value}" was normalized to boolean true.`,
        };
      }

      if (["false", "no", "n", "off", "disabled", "0"].includes(normalized)) {
        return {
          value: false,
          reason: `"${value}" was normalized to boolean false.`,
        };
      }
    }

    return {
      value: fallback,
      reason: `Unsupported boolean value was normalized to ${fallback}.`,
    };
  }

  /**
   * ------------------------------------------------------------
   * Malformed structures
   * ------------------------------------------------------------
   */

  convertMalformedField(rawField, index) {
    /**
     * String field:
     *
     * "Product Name"
     *
     * becomes:
     *
     * {
     *   name: "product_name",
     *   label: "Product Name",
     *   type: "string",
     *   ...
     * }
     */
    if (typeof rawField === "string") {
      const label = rawField.trim() || `Field ${index + 1}`;

      return {
        success: true,
        destructive: false,
        field: {
          name: this.normalizeFieldName(label, label, index),
          label,
          type: "string",
          description: "",
          required: false,
          multiple: false,
          active: true,
        },
      };
    }

    /**
     * Number field.
     */
    if (typeof rawField === "number") {
      const label = `Field ${index + 1}`;

      return {
        success: true,
        destructive: true,
        field: {
          name: `field_${index + 1}`,
          label,
          type: "number",
          description: "",
          required: false,
          multiple: false,
          active: true,
        },
      };
    }

    /**
     * Boolean field.
     */
    if (typeof rawField === "boolean") {
      const label = `Field ${index + 1}`;

      return {
        success: true,
        destructive: true,
        field: {
          name: `field_${index + 1}`,
          label,
          type: "boolean",
          description: "",
          required: false,
          multiple: false,
          active: rawField,
        },
      };
    }

    return {
      success: false,
      destructive: false,
      field: null,
    };
  }

  tryConvertFields(value) {
    if (value && typeof value === "object" && !Array.isArray(value)) {
      /**
       * Some malformed definitions may have:
       *
       * fields: {
       *   email: {...},
       *   name: {...}
       * }
       *
       * Convert object values into field array.
       */
      const entries = Object.entries(value);

      if (entries.length === 0) {
        return {
          success: true,
          fields: [],
          destructive: false,
        };
      }

      const fields = entries.map(([key, field]) => {
        if (field && typeof field === "object" && !Array.isArray(field)) {
          return {
            ...field,
            name:
              field.name ||
              key ||
              field.label ||
              "field",
          };
        }

        return key;
      });

      return {
        success: true,
        fields,
        destructive: false,
      };
    }

    /**
     * Single field object accidentally supplied instead
     * of an array.
     */
    if (value && typeof value === "object") {
      return {
        success: true,
        fields: [value],
        destructive: true,
      };
    }

    return {
      success: false,
      fields: [],
      destructive: false,
    };
  }

  /**
   * ------------------------------------------------------------
   * Final validation
   * ------------------------------------------------------------
   */

  validateDefinition(value) {
    const problems = [];

    if (!value || typeof value !== "object" || Array.isArray(value)) {
      problems.push({
        code: "definition_not_object",
        path: "",
        field: "Definition",
        message: "The definition must be a JSON object.",
        explanation: "The top-level definition must be an object.",
      });

      return problems;
    }

    if (!Array.isArray(value.fields)) {
      problems.push({
        code: "fields_not_array",
        path: "fields",
        field: "fields",
        message: '"fields" must be an array.',
        explanation:
          'The definition builder expects "fields" to contain an array of field objects.',
      });

      return problems;
    }

    const names = new Set();

    value.fields.forEach((field, index) => {
      const path = `fields[${index}]`;

      if (!field || typeof field !== "object" || Array.isArray(field)) {
        problems.push({
          code: "invalid_field",
          path,
          field: `Field ${index + 1}`,
          message: `Field ${index + 1} must be an object.`,
          explanation:
            "Each item in fields must contain field configuration properties.",
        });

        return;
      }

      if (
        typeof field.name !== "string" ||
        !IDENTIFIER_PATTERN.test(field.name)
      ) {
        problems.push({
          code: "invalid_field_name",
          path: `${path}.name`,
          field: field.label || field.name || `Field ${index + 1}`,
          message: `Field "${field.label || field.name || `Field ${index + 1}`}" has an invalid name.`,
          explanation:
            "Field names must use letters, numbers and underscores and must begin with a letter or underscore.",
        });
      }

      if (typeof field.name === "string") {
        if (names.has(field.name)) {
          problems.push({
            code: "duplicate_field_name",
            path: `${path}.name`,
            field: field.name,
            message: `Field name "${field.name}" is duplicated.`,
            explanation:
              "Every field needs a unique name so the builder can address it reliably.",
          });
        }

        names.add(field.name);
      }

      if (!this.options.supportedTypes.includes(field.type)) {
        problems.push({
          code: "unsupported_type",
          path: `${path}.type`,
          field: field.label || field.name || `Field ${index + 1}`,
          message: `Field "${field.label || field.name || `Field ${index + 1}`}" has an unsupported type.`,
          explanation:
            "The field type is not supported by the current definition builder.",
        });
      }

      ["required", "multiple", "active"].forEach((property) => {
        if (typeof field[property] !== "boolean") {
          problems.push({
            code: "invalid_boolean",
            path: `${path}.${property}`,
            field: field.label || field.name || `Field ${index + 1}`,
            message: `${property} must be a boolean.`,
            explanation: `The "${property}" property must be true or false.`,
          });
        }
      });
    });

    return problems;
  }

  /**
   * ------------------------------------------------------------
   * Change log helpers
   * ------------------------------------------------------------
   */

  change({
    path,
    field,
    originalValue,
    repairedValue,
    reason,
    destructive = false,
    category = "repair",
  }) {
    return {
      id: this.generateId(),
      path,
      field,
      originalValue: this.clone(originalValue),
      repairedValue: this.clone(repairedValue),
      reason,
      destructive,
      category,
      status: "pending",
    };
  }

  warning(code, message) {
    return {
      code,
      message,
      severity: "warning",
    };
  }

  generateId() {
    return `repair_${Date.now()}_${Math.random()
    .toString(36)
    .slice(2, 9)}`;
  }

  /**
   * ------------------------------------------------------------
   * Utilities
   * ------------------------------------------------------------
   */

  clone(value) {
    if (value === undefined) {
      return undefined;
    }

    if (value === null) {
      return null;
    }

    return JSON.parse(JSON.stringify(value));
  }

  humanizeJsonParseError(error) {
    if (!error) {
      return "The JSON could not be parsed.";
    }

    const message = error.message || String(error);

    /**
     * Firefox/Chrome generally expose:
     *
     * Unexpected token ... in JSON at position 123
     */
    const positionMatch = message.match(/position\s+(\d+)/i);

    if (positionMatch) {
      return `Invalid JSON near character ${positionMatch[1]}. ${message}`;
    }

    return message;
  }
}

export const jsonDefinitionRepair = new JsonDefinitionRepair();

export default JsonDefinitionRepair;