
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "form",
    "input",
    "submit",
    "submitLabel",
    "status",
    "statusTitle",
    "statusMessage",
    "resultSummary"
  ]

  static values = {
    url: String,
    data: Object
  }

  connect() {
    this.abortController = null
    this.requestNumber = 0

    this.originalPayload = this.readInitialPayload()

    this.setLoading(false)

    this.setStatus(
        "Ready to search",
        `Search the ${this.originalPayload.nodes.length} entities already loaded in the graph.`,
        "ready"
    )
  }

  disconnect() {
    this.abortController?.abort()
  }

  readInitialPayload() {
    // Preferred source: JSON supplied directly to this controller.
    if (this.hasDataValue && this.dataValue) {
      return this.normalizePayload(this.dataValue)
    }

    // Alternative: JSON supplied by the main graph controller.
    const main = document.querySelector(
        '[data-controller~="relationship-graph"]'
    )

    if (main?.dataset.graphSearchDataValue) {
      try {
        return this.normalizePayload(
            JSON.parse(main.dataset.graphSearchDataValue)
        )
      } catch (error) {
        console.error(
            "[GraphSearch] Unable to read initial graph data:",
            error
        )
      }
    }

    // Fallback: use graph data embedded in the page, if available.
    const dataElement = document.querySelector(
        "#relationship-graph-data"
    )

    if (dataElement) {
      try {
        return this.normalizePayload(
            JSON.parse(dataElement.textContent)
        )
      } catch (error) {
        console.error(
            "[GraphSearch] Unable to parse embedded graph data:",
            error
        )
      }
    }

    console.warn(
        "[GraphSearch] No initial graph data was found. " +
        "Check the data-value attribute on the graph or search controller."
    )

    return {
      nodes: [],
      edges: [],
      meta: {}
    }
  }

  normalizePayload(payload) {
    // Support the common graph formats used by Rails endpoints.
    const root = payload?.data ?? payload ?? {}
    const graph = root.graph ?? root

    const nodes =
        graph.nodes ??
        graph.entities ??
        root.nodes ??
        root.entities ??
        []

    const edges =
        graph.edges ??
        graph.relationships ??
        root.edges ??
        root.relationships ??
        root.links ??
        []

    return {
      nodes: Array.isArray(nodes)
          ? nodes.filter(item => item && typeof item === "object")
          : [],
      edges: Array.isArray(edges)
          ? edges.filter(item => item && typeof item === "object")
          : [],
      meta: root.meta ?? {}
    }
  }

  async search(event) {
    event?.preventDefault()

    const query = this.hasInputTarget
        ? this.inputTarget.value.trim()
        : ""

    if (query.length > 200) {
      this.setStatus(
          "Search not submitted",
          "Your search must not exceed 200 characters.",
          "error"
      )
      return
    }

    // Search the original graph data using the matching approach
    // from your working controller. This avoids false zero counts
    // caused by assuming an incorrect API response structure.
    const payload = this.originalPayload
    const needle = query.toLocaleLowerCase()

    this.setLoading(true)

    try {
      const matches = payload.nodes.filter(node => {
        const values = [
          node.id,
          node.name,
          node.title,
          node.label,
          node.slug,
          node.summary,
          node.description,
          node.status,
          node.workflow_state,
          node.entity_type_id,
          node.entity_type,
          node.entity_type_name,
          node.type,
          node.identifier,
          node.external_id
        ]

        return !needle || values.some(value =>
            String(value ?? "")
                .toLocaleLowerCase()
                .includes(needle)
        )
      })

      const matchingIds = new Set(
          matches.flatMap(node => {
            const ids = [
              node.id,
              node.identifier,
              node.slug
            ]

            return ids
                .filter(value => value !== null && value !== undefined)
                .map(String)
          })
      )

      const relationships = payload.edges.filter(edge => {
        const source = String(
            edge.source ??
            edge.source_id ??
            edge.source_entity_id ??
            edge.from ??
            ""
        )

        const target = String(
            edge.target ??
            edge.target_id ??
            edge.target_entity_id ??
            edge.to ??
            ""
        )

        const relationshipValues = [
          edge.label,
          edge.name,
          edge.type,
          edge.relationship_kind,
          edge.relationship_type,
          edge.relationship_type_name
        ]

        const relationshipMatches =
            !needle ||
            relationshipValues.some(value =>
                String(value ?? "")
                    .toLocaleLowerCase()
                    .includes(needle)
            )

        const connectsMatchingEntities =
            matchingIds.has(source) || matchingIds.has(target)

        return !needle ||
            connectsMatchingEntities ||
            relationshipMatches
      })

      // Publish the actual matching records for any results panel
      // listening to graph-search:results.
      this.dispatch("results", {
        detail: {
          query,
          entities: matches,
          nodes: matches,
          relationships,
          edges: relationships,
          totalEntities: matches.length,
          totalRelationships: relationships.length
        }
      })

      if (this.hasResultSummaryTarget) {
        this.resultSummaryTarget.textContent =
            `${matches.length} ${matches.length === 1 ? "entity" : "entities"} matched` +
            ` and ${relationships.length} ${relationships.length === 1 ? "relationship" : "relationships"} matched.`

        this.resultSummaryTarget.classList.remove("hidden")
      }

      if (query && matches.length === 0 && relationships.length === 0) {
        this.setStatus(
            "No matching records",
            `No entities or relationships in the currently loaded graph matched "${query}".`,
            "ready"
        )
      } else {
        this.setStatus(
            "Search completed",
            query
                ? `Found ${matches.length} matching entities and ${relationships.length} matching relationships in the loaded graph.`
                : `Showing all ${payload.nodes.length} entities and ${payload.edges.length} relationships in the loaded graph.`,
            "success"
        )
      }
    } catch (error) {
      console.error("[GraphSearch] Search failed:", error)

      this.setStatus(
          "Search failed",
          error.message || "Unable to search the loaded graph.",
          "error"
      )

      if (this.hasResultSummaryTarget) {
        this.resultSummaryTarget.classList.add("hidden")
      }
    } finally {
      this.setLoading(false)
    }
  }

  clear(event) {
    event?.preventDefault()

    this.abortController?.abort()
    this.requestNumber++

    if (this.hasInputTarget) {
      this.inputTarget.value = ""
    }

    this.dispatch("results", {
      detail: {
        query: "",
        entities: this.originalPayload.nodes,
        nodes: this.originalPayload.nodes,
        relationships: this.originalPayload.edges,
        edges: this.originalPayload.edges,
        totalEntities: this.originalPayload.nodes.length,
        totalRelationships: this.originalPayload.edges.length,
        cleared: true
      }
    })

    if (this.hasResultSummaryTarget) {
      this.resultSummaryTarget.textContent = ""
      this.resultSummaryTarget.classList.add("hidden")
    }

    this.setLoading(false)

    this.setStatus(
        "Search cleared",
        `The original graph with ${this.originalPayload.nodes.length} entities and ${this.originalPayload.edges.length} relationships remains available.`,
        "ready"
    )

    this.inputTarget?.focus()
  }

  setLoading(loading) {
    if (this.hasStatusTarget) {
      this.statusTarget.setAttribute(
          "aria-busy",
          String(loading)
      )
    }

    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = loading
    }

    if (this.hasSubmitLabelTarget) {
      this.submitLabelTarget.textContent = loading
          ? "Searching…"
          : "Search"
    }
  }

  setStatus(title, message, state = "ready") {
    if (this.hasStatusTitleTarget) {
      this.statusTitleTarget.textContent = title
    }

    if (this.hasStatusMessageTarget) {
      this.statusMessageTarget.textContent = message
    }

    if (!this.hasStatusTarget) return

    const styles = {
      ready: "border-slate-200 bg-slate-50",
      loading: "border-blue-200 bg-blue-50",
      success: "border-emerald-200 bg-emerald-50",
      error: "border-red-200 bg-red-50"
    }

    this.statusTarget.classList.remove(
        "border-slate-200",
        "bg-slate-50",
        "border-blue-200",
        "bg-blue-50",
        "border-emerald-200",
        "bg-emerald-50",
        "border-red-200",
        "bg-red-50"
    )

    this.statusTarget.classList.add(
        ...(styles[state] || styles.ready).split(" ")
    )
  }
}