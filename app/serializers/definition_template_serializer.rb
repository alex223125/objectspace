class DefinitionTemplateSerializer
  def initialize(definition_template)
    @definition_template = definition_template
  end

  def as_json(*)
    definition_template.to_catalog_hash
  end

  private

  attr_reader :definition_template
end