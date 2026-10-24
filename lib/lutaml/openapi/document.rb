# frozen_string_literal: true

module Lutaml
  module Openapi
    # An OpenAPI document: the root object (3.1 shape).
    class Document < Lutaml::Model::Serializable
      DIALECTS = {
        "3.1" => "https://spec.openapis.org/oas/3.1/dialect/base",
      }.freeze

      attribute :openapi, :string
      attribute :info, :hash
      attribute :servers, :hash, collection: true
      attribute :paths, :hash
      attribute :webhooks, :hash
      attribute :components, :hash
      attribute :security, :hash, collection: true
      attribute :tags, :hash, collection: true
      attribute :external_docs, :hash

      # Keywords the model does not name (vendor extensions, dialect
      # additions): collected verbatim, re-emitted on serialization.
      attribute :extensions, :hash, default: -> { {} }

      # which OpenAPI dialect the source was written in ("3.0"/"3.1")
      attribute :source_dialect, :string

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
    end
  end
end
