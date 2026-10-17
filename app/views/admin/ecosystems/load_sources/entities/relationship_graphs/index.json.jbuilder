

  payload = @graph_payload || @graph_data || {}

payload = payload.as_json if payload.respond_to?(:as_json)
payload = payload.stringify_keys if payload.respond_to?(:stringify_keys)

nodes = payload["nodes"] || payload[:nodes] || @nodes || []
edges = payload["edges"] || payload[:edges] || @edges || []
meta = payload["meta"] || payload[:meta] || @meta || {}

meta = meta.as_json if meta.respond_to?(:as_json)
meta = meta.stringify_keys if meta.respond_to?(:stringify_keys)

meta = {} unless meta.is_a?(Hash)

nodes = nodes.to_a
edges = edges.to_a

node_count = meta["node_count"] || nodes.size
edge_count = meta["edge_count"] || edges.size
connected_count = meta["connected_node_count"]
isolated_count = meta["isolated_node_count"]

if connected_count.nil? || isolated_count.nil?
  connected_ids = edges.each_with_object({}) do |edge, ids|
    edge = edge.as_json if edge.respond_to?(:as_json)
    next unless edge.respond_to?(:[])

    source = edge["source_id"] || edge["source"] || edge["from_id"]
    target = edge["target_id"] || edge["target"] || edge["to_id"]

    ids[source.to_s] = true unless source.nil?
    ids[target.to_s] = true unless target.nil?
  end

  connected_count ||= nodes.count do |node|
    node = node.as_json if node.respond_to?(:as_json)
    id = node.respond_to?(:[]) ? (node["id"] || node[:id]) : nil
    id && connected_ids.key?(id.to_s)
  end

  isolated_count ||= [node_count.to_i - connected_count.to_i, 0].max
end


json.nodes nodes
json.edges edges

json.meta do
  json.node_count node_count.to_i
  json.edge_count edge_count.to_i
  json.connected_node_count connected_count.to_i
  json.isolated_node_count isolated_count.to_i
  json.depth (meta["depth"] || 1).to_i
  json.limit (meta["limit"] || node_count).to_i
  json.truncated !!meta["truncated"]
  json.root_entity_id meta["root_entity_id"]
  json.states meta["states"] || []
  json.generated_at meta["generated_at"] || Time.current.iso8601
end