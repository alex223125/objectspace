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
    this.originalPayload = this.readInitialPayload()
    this.setLoading(false)
    this.setStatus(
      "Ready to search",
      "Search entity names, identifiers, types, and relationship labels.",
      "ready"
    )
  }

  disconnect() {
    this.abortController?.abort()
  }

  readInitialPayload() {
    if (this.hasDataValue && this.dataValue) {
      return this.normalizePayload(this.dataValue)
    }

    const main = document.querySelector(
      '[data-controller~="relationship-graph"]'
    )

    if (main?.dataset.graphSearchDataValue) {
      try {
        return this.normalizePayload(
          JSON.parse(main.dataset.graphSearchDataValue)
        )
      } catch (error) {
        console.error("Unable to read initial graph data:", error)
      }
    }

    return { nodes: [], edges: [], meta: {} }
  }

  normalizePayload(payload) {
    return {
      ...payload,
      nodes: Array.isArray(payload?.nodes) ? payload.nodes : [],
      edges: Array.isArray(payload?.edges) ? payload.edges : [],
      meta: payload?.meta || {}
    }
  }

  async search(event) {
    event.preventDefault()

    const query = this.inputTarget.value.trim()

    if (query.length > 200) {
      this.setStatus(
        "Search not submitted",
        "Your search must not exceed 200 characters.",
        "error"
      )
      return
    }

    // Search the existing graph locally. Do not request the HTML page
    // as JSON and do not replace the graph with an empty API response.
    const payload = this.originalPayload
    const needle = query.toLocaleLowerCase()

    const matches = payload.nodes.filter((node) => {
      const values = [
        node.id,
        node.name,
        node.slug,
        node.summary,
        node.status,
        node.workflow_state,
        node.entity_type_id,
        node.entity_type,
        node.type,
        node.identifier
      ]

      return !needle || values.some((value) =>
        String(value ?? "").toLocaleLowerCase().includes(needle)
      )
    })

    const matchingIds = new Set(matches.map((node) => String(node.id)))

    const edges = payload.edges.filter((edge) => {
      const source = String(
        edge.source ?? edge.source_id ?? edge.source_entity_id ?? ""
      )
      const target = String(
        edge.target ?? edge.target_id ?? edge.target_entity_id ?? ""
      )

      const label = [
        edge.label,
        edge.relationship_kind,
        edge.relationship_type
      ].some((value) =>
        String(value ?? "").toLocaleLowerCase().includes(needle)
      )

      if (label && !needle) return true

      return matchingIds.has(source) && matchingIds.has(target)
    })

    this.resultSummaryTarget.classList.remove("hidden")
    this.resultSummaryTarget.textContent =
      `${matches.length} ${matches.length === 1 ? "entity" : "entities"} matched` +
      ` and ${edges.length} ${edges.length === 1 ? "relationship" : "relationships"} matched.`

    if (query && matches.length === 0) {
      this.setStatus(
        "No matching entities",
        `No entity matched "${query}". The original graph has been preserved.`,
        "ready"
      )
      return
    }

    // This is informational only. Keep the original graph untouched:
    // no search-results event is dispatched to the visualization.
    this.setStatus(
      "Search completed",
      query
        ? `Found ${matches.length} matching entities. The original graph remains visible.`
        : `Showing the original graph containing ${payload.nodes.length} entities.`,
      "success"
    )
  }

  clear() {
    this.inputTarget.value = ""
    this.resultSummaryTarget.textContent = ""
    this.resultSummaryTarget.classList.add("hidden")

    this.setLoading(false)
    this.setStatus(
      "Search cleared",
      `The original graph with ${this.originalPayload.nodes.length} entities remains visible.`,
      "ready"
    )

    this.inputTarget.focus()
  }

  setLoading(loading) {
    if (this.hasStatusTarget) {
      this.statusTarget.setAttribute("aria-busy", String(loading))
    }

    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = loading
    }

    if (this.hasSubmitLabelTarget) {
      this.submitLabelTarget.textContent = loading ? "Searching…" : "Search"
    }
  }

  setStatus(title, message, state) {
    if (this.hasStatusTitleTarget) {
      this.statusTitleTarget.textContent = title
    }

    if (this.hasStatusMessageTarget) {
      this.statusMessageTarget.textContent = message
    }

    const styles = {
      ready: "border-slate-200 bg-slate-50",
      loading: "border-blue-200 bg-blue-50",
      success: "border-emerald-200 bg-emerald-50",
      error: "border-red-200 bg-red-50"
    }

    if (this.hasStatusTarget) {
      this.statusTarget.className =
        `mt-5 rounded-2xl border p-4 ${styles[state] || styles.ready}`
    }
  }
}
