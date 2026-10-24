# frozen_string_literal: true

module Lutaml
  # OpenAPI 3.0/3.1 as a lossless lutaml-model.
  #
  # The 3.1 shape is the model (its Schema objects are JSON Schema
  # 2020-12); 3.0 documents are normalized into it by the 3.0 frontend
  # while `source_dialect` is kept, so serialization re-emits 3.0
  # semantics for 3.0 sources. Anything unmodeled rides the extensions
  # catch-all — documents round-trip verbatim.
  module Openapi
    autoload :VERSION, "lutaml/openapi/version"
    autoload :Document, "lutaml/openapi/document"

    require "lutaml/model"
  end
end
