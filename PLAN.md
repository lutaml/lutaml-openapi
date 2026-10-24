# PLAN.md — lutaml-openapi: OpenAPI as a model-based standard

Closes [metanorma/metanorma-ogc#153](https://github.com/metanorma/metanorma-ogc/issues/153)
("Model-based standard (OpenAPI)", open since 2020-06-15): make the OpenAPI
definition the **primary publication** of the OGC API family, with the
implementers' guide and most of the normative OGC/ISO publication **driven by
the OpenAPI model** — the ISO-10303 play (expressir → lutaml-express →
metanorma-plugin-lutaml) applied to OpenAPI.

## Mission

Parse OpenAPI **3.0 and 3.1** documents into a lossless lutaml-model object
graph; render them as (a) sovereign single-file human documentation and
(b) normative Metanorma sections through `metanorma-plugin-openapi`, with
Markdown descriptions properly converted to AsciiDoc via **coradoc**.

## Repos and org parity

| Repo | Org | Role | Setup cloned from |
|---|---|---|---|
| `lutaml/lutaml-openapi` | lutaml | the model gem | lutaml-xsd / lutaml-jsonschema (generic-rake CI, cimas release train, rubocop baseline, BSD-2-Clause) |
| `metanorma/metanorma-plugin-openapi` | metanorma | the Metanorma plugin | metanorma-plugin-lutaml (rake.yml + release.yml, BSD-2-Clause, Ribose authorship) |

Team access mirrors siblings: lutaml → staff:admin, developers:push,
ci:push, express:push, editors:push; metanorma → staff:admin,
developers:push, ci:push, editors:push.

## Architecture

```
OpenAPI 3.0/3.1 (YAML/JSON, CommonMark descriptions)
        │ parse (3.0 normalized into the 3.1-shaped model; source dialect kept)
        ▼
Lutaml::Openapi::Document ── components.schemas ──► Lutaml::Jsonschema::Schema
        │                                            (lossless: map_unmapped)
        ├─► SPA (own Vue frontend, lutaml-xsd precedent)          [human guide]
        └─► metanorma-plugin-openapi ── Coradoc.convert(md → adoc) [normative]
              requirements-class rendering per the OGC API - Features
              "requirements class OpenAPI 3.1" pattern (ModSpec-aware)
```

### Design decisions

1. **3.1-shaped model, 3.0 frontend.** 3.1 is the superset and its Schema
   objects are 2020-12 — lutaml-jsonschema's native dialect. The 3.0 parser
   normalizes into the 3.1 shape (`nullable` → `type: [T, null]`,
   boolean `exclusiveMinimum` → numeric, `binary`/`file` formats) while
   `source_dialect` is kept on the document; serialization re-emits 3.0
   semantics for 3.0 sources. Anything unmodeled rides `map_unmapped`
   extensions — the document round-trips verbatim.
2. **Descriptions are Markdown (CommonMark per OAS).** The model stores them
   verbatim (losslessness). Conversion to AsciiDoc happens at render time via
   `Coradoc.convert(desc, from: :markdown, to: :asciidoc)` — the coradoc tree
   is the manipulation point (opoudjis's pipeline in metanorma-ogc#153). The
   SPA keeps its own markdown-lite renderer.
3. **Schema layer is delegated.** `components.schemas` materializes as
   `Lutaml::Jsonschema::Schema` — schema-level features (diff, exports, meta-
   schema validation) come free and stay MECE with lutaml-jsonschema.
4. **The plugin targets ModSpec.** metanorma#125 shipped the model-based
   standards machinery (modspec 0.2.3). The plugin renders
   requirements-class sections that reference/extend OpenAPI artifacts —
   the Features API pattern — not free-form prose.
5. **Own SPA frontend** in lutaml-openapi (lutaml-xsd precedent), seeded
   from lutaml-jsonschema's frontend patterns (i18n catalog, axe audit in
   the default rake gate, browser/PDF gates, determinism guard).

## Milestones

- **M0 — repos live with sibling parity** (this milestone): both repos
  created, teams set, CI + release workflows, lint baseline, first PR merged.
  *Done-when:* both repos' CI green on main; team access matches siblings.
- **M1 — 3.1 model + 3.0 frontend parser**: `Document`, `Path`, `Operation`,
  `Components`, `Response`, `Parameter`, `RequestBody`, `SecurityScheme`,
  `Server`; schemas as `Lutaml::Jsonschema::Schema`; lossless round-trip;
  both OGC corpus documents (oas30 + oas31) parse, round-trip, and
  meta-validate. *Done-when:* both corpus files round-trip with zero
  modeled-keyword loss (golden specs); unknown keywords preserved.
- **M2 — SPA**: OpenAPI human guide (paths/operations/components views,
  search, builder for examples); i18n + AA audit + determinism + browser
  gates as in lutaml-jsonschema. *Done-when:* the two corpus documents render
  as single-file SPAs that boot in headless Chrome and pass axe AA.
- **M3 — `metanorma-plugin-openapi`**: `lutaml_openapi` /
  `openapi_requirements_class` blocks emitting normative AsciiDoc sections;
  descriptions through coradoc; ModSpec requirement-class alignment.
  *Done-when:* an AsciiDoc document embedding the Features API OpenAPI
  renders through metanorma into valid HTML/PDF with normative sections.
- **M4 — OGC acceptance**: a metanorma-ogc#153 close-out demonstration —
  OGC API - Features Part 1 published as (a) our SPA and (b) a Metanorma
  document with model-driven normative sections. *Done-when:* the demonstration
  is linked on metanorma-ogc#153 and the ticket can close.

## Non-goals (for now)

- OpenAPI 2.0/Swagger; AsyncAPI.
- Markdown *authoring* of OpenAPI (opoudjis's coradoc round-trip) — the 2026
  note makes requirements authoring the focus; revisit later.
- We do not host/serve anything: artifacts are sovereign files.

## Standing laws (inherited)

lutaml-model serialization only (no hand-rolled to_h); autoload over
require_relative; PRs only, never commit to main; no AI attribution; exact
release versions from the owner; real objects in specs, never doubles.
