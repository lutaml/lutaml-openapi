# Lutaml::Openapi

OpenAPI 3.0/3.1 as a lossless [lutaml-model](https://github.com/lutaml/lutaml-model)
object graph — the model layer for model-based OpenAPI standards
(metanorma-ogc#153).

```ruby
require "lutaml/openapi"

doc = Lutaml::Openapi.parse(File.read("ogcapi-features-1.yaml"))
doc.openapi         # => "3.1.0"
doc.source_dialect  # => "3.1" (or "3.0" for normalized-on-read sources)
doc.info["title"]   # => "OGC API - Features - Part 1: Core"
doc.paths           # => { "/collections" => { "get" => { ... } } }
doc.to_json         # lossless re-serialization
```

## Losslessness

The document is stored **verbatim**: every parsed section is kept exactly as
the source carried it, unmodeled keywords (vendor `x-*`, stray root sections)
re-emit on serialization via `map_unmapped`, and the wire round trip
(`parse → to_json`) is asserted losslessly for the **full 19-document OGC API
corpus** vendored in `spec/fixtures` — 3.0 and 3.1 dialects, YAML and JSON.
3.0 documents need no denormalization pass; see the architecture notes in
[CLAUDE.md](CLAUDE.md).

## Typed schema view

`Document#schemas` materializes `components.schemas` as
`Lutaml::Jsonschema::Schema` objects — 3.0 dialect semantics normalize into
the 3.1 shape here (`nullable: true` becomes the null-member type union,
`exclusiveMinimum: true` folds into the bound). This is the view
[metanorma-plugin-openapi](https://github.com/metanorma/metanorma-plugin-openapi)
renders from.

## SPA

`Lutaml::Openapi::Spa.generate(doc)` builds a standalone single-file
documentation site (Vue bundle + document data inlined). The frontend ships
an en+ar locale switch with RTL layout and passes an axe AA audit in CI.

See [PLAN.md](PLAN.md) for the program plan.
