# frozen_string_literal: true

require "lutaml/jsonschema"
require "lutaml/model"
require "yeptris/yaml"
require "json"

module Lutaml
  # OpenAPI 3.0/3.1 as a lossless lutaml-model.
  #
  # The document is stored verbatim — what was parsed is what the wire
  # re-emits, so losslessness is structural rather than an emit-time
  # transform. The 3.1 shape is the typed view: `source_dialect` tracks
  # the frontend, and 3.0 schema nodes are normalized into JSON Schema
  # 2020-12 by the 3.0 frontend when the typed layer materializes them.
  # Anything unmodeled rides the extensions catch-all — documents
  # round-trip verbatim.
  module Openapi
    autoload :CorpusAudit, "lutaml/openapi/corpus_audit"
    autoload :Spa, "lutaml/openapi/spa"
    autoload :VERSION, "lutaml/openapi/version"
    autoload :Document, "lutaml/openapi/document"
    autoload :Oas30, "lutaml/openapi/oas30"

    # Parse an OpenAPI document (YAML or JSON, 3.0 or 3.1) into a
    # lossless {Document}.
    def self.parse(string)
      data = parse_raw(string)
      dialect = data["openapi"].to_s.start_with?("3.0") ? "3.0" : "3.1"

      Document.from_json(JSON.generate(data)).tap do |doc|
        doc.source_dialect = dialect
      end
    end

    def self.parse_raw(string)
      stripped = string.lstrip
      if stripped.start_with?("{", "[")
        require "yeptris/json"
        Yeptris::JSON.load(string)
      else
        Yeptris::YAML.load(string)
      end
    end
  end
end
