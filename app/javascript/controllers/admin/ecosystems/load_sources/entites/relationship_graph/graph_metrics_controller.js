
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "nodes",
    "edges",
    "connected",
    "isolated",
    "coverage",
    "status",
    "progress"
  ]

  static values = {
    data: { type: Object, default: {} }
  }

  connect() {
    this.handleUpdate = this.handleUpdate.bind(this)

    this.element.addEventListener(
        "relationship-graph:updated",
        this.handleUpdate
    )

    this.refresh()
  }

  disconnect() {
    this.element.removeEventListener(
        "relationship-graph:updated",
        this.handleUpdate
    )
  }

  handleUpdate(event) {
    if (event.detail?.data) {
      this.dataValue = event.detail.data
    } else if (event.detail?.nodes || event.detail?.edges) {
      this.dataValue = {
        ...this.dataValue,
        nodes: event.detail.nodes ?? this.dataValue.nodes ?? [],
        edges: event.detail.edges ?? this.dataValue.edges ?? []
      }
    }

    this.refresh()
  }

  refresh() {
    const data = this.dataValue || {}
    const nodes = Array.isArray(data.nodes) ? data.nodes : []
    const edges = Array.isArray(data.edges) ? data.edges : []
    const meta = data.meta || {}

    const connectedIds = new Set()

    edges.forEach((edge) => {
      const source = edge.source_id ?? edge.source ?? edge.from
      const target = edge.target_id ?? edge.target ?? edge.to

      if (source != null && target != null) {
        connectedIds.add(String(source))
        connectedIds.add(String(target))
      }
    })

    const connected = nodes.filter((node) =>
        connectedIds.has(String(node.id))
    ).length

    const isolated = Math.max(nodes.length - connected, 0)

    const coverage = nodes.length > 0
        ? Math.round((connected / nodes.length) * 100)
        : 0

    this.setText("nodes", this.format(meta.node_count ?? nodes.length))
    this.setText("edges", this.format(meta.edge_count ?? edges.length))
    this.setText("connected", this.format(
        meta.connected_node_count ?? connected
    ))
    this.setText("isolated", this.format(
        meta.isolated_node_count ?? isolated
    ))
    this.setText("coverage", `${coverage}%`)

    if (this.hasProgressTarget) {
      this.progressTarget.style.width = `${coverage}%`
      this.progressTarget.setAttribute("role", "progressbar")
      this.progressTarget.setAttribute("aria-valuemin", "0")
      this.progressTarget.setAttribute("aria-valuemax", "100")
      this.progressTarget.setAttribute("aria-valuenow", String(coverage))
      this.progressTarget.setAttribute(
          "aria-label",
          "Connected entity coverage"
      )
    }

    if (this.hasStatusTarget) {
      this.statusTarget.textContent = nodes.length === 0
          ? "No entities available"
          : edges.length === 0
              ? "Entities loaded · No relationships returned"
              : "Graph metrics updated"
    }
  }

  setText(targetName, value) {
    const hasTarget = {
      nodes: this.hasNodesTarget,
      edges: this.hasEdgesTarget,
      connected: this.hasConnectedTarget,
      isolated: this.hasIsolatedTarget,
      coverage: this.hasCoverageTarget
    }[targetName]

    if (!hasTarget) return

    const targets = {
      nodes: this.nodesTargets,
      edges: this.edgesTargets,

      connected: this.connectedTargets,
      isolated: this.isolatedTargets,
      coverage: this.coverageTargets
    }[targetName]

    targets.forEach((target) => {
      target.textContent = value
    })
  }

  format(value) {
    const number = Number(value)
    return Number.isFinite(number)
        ? new Intl.NumberFormat().format(number)
        : "—"
  }
}