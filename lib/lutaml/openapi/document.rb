# frozen_string_literal: true

module Lutaml
  module Openapi
    # An OpenAPI document: the root object, stored verbatim.
    #
    # Losslessness is structural: every parsed section is kept exactly
    # as the source carried it (3.0 dialects included), so both wire
    # serializations round-trip without an emit-time transform. The
    # typed schema view (#schemas) is where dialects converge — it
    # materializes lutaml-jsonschema models from the 3.1-normalized
    # shape, applying the 3.0 frontend for 3.0 sources on demand.
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
      # the typed view for diff/exports/validation. Schema nodes are
      # normalized into the 3.1 shape here: this is the only place the
      # 3.0 frontend applies.
      def schemas
        ((components && components["schemas"]) || {}).to_h do |name, value|
          shape = source_dialect == "3.0" ? Oas30.normalize(value) : value
          [name, Lutaml::Jsonschema::Schema.from_json(JSON.generate(shape))]
        end
      end

      def to_hash(options = {})
        hash = super
        hash.delete("source_dialect") # internal: tracks the frontend used
        hash
      end
    end
  end
end
