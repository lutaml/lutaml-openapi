# frozen_string_literal: true

module Lutaml
  module Openapi
    # An OpenAPI document: the root object (3.1 shape).
    #
    # Losslessness lives on the raw hash: `components` (and every other
    # section) is kept verbatim, and 3.0 sources denormalize back on
    # serialization. The typed schema view (#schemas) materializes
    # lutaml-jsonschema models on demand — that view applies the
    # jsonschema model's own normalizations, so round-trip fidelity is
    # asserted on the hash, not the typed layer.
    class Document < Lutaml::Model::Serializable
      attribute :openapi, :string
      attribute :source_dialect, :string
      attribute :info, :hash
      attribute :servers, :hash, collection: true
      attribute :paths, :hash
      attribute :webhooks, :hash
      attribute :security, :hash, collection: true
      attribute :tags, :hash, collection: true
      attribute :external_docs, :hash
      attribute :components, :hash

      # Keywords the model does not name (vendor extensions, dialect
      # additions): collected verbatim, re-emitted on serialization.
      attribute :extensions, :hash, default: -> { {} }

      json do
        map "openapi", to: :openapi
        map "info", to: :info
        map "servers", to: :servers
        map "paths", to: :paths
        map "webhooks", to: :webhooks
        map "components", to: :components
        map "security", to: :security
        map "tags", to: :tags
        map "externalDocs", to: :external_docs
        map_unmapped to: :extensions
      end

      # components.schemas as { name => Lutaml::Jsonschema::Schema } —
      # the typed view for diff/exports/validation.
      def schemas
        ((components && components["schemas"]) || {}).to_h do |name, value|
          [name, Lutaml::Jsonschema::Schema.from_json(JSON.generate(value))]
        end
      end

      def to_hash(options = {})
        hash = super
        hash.delete("source_dialect") # internal: tracks the frontend used
        return hash unless source_dialect == "3.0"

        Oas30.denormalize(hash)
      end
    end
  end
end
