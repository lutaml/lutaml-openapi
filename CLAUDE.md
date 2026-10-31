# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`lutaml-openapi` parses OpenAPI 3.0/3.1 documents into lutaml-model objects and generates a single-file SPA documentation site from them. It is the model layer for model-based OpenAPI standards (metanorma-ogc#153); `metanorma-plugin-openapi` renders these models into Metanorma documents.

## Commands

```sh
bundle exec rspec                          # full suite (corpus golden included)
bundle exec rspec spec/openapi_spec.rb     # one file
bundle exec rubocop                        # lint (-a to autofix; .rubocop_todo.yml holds baselined offenses)
bundle exec rake                           # spec + rubocop + frontend:audit (axe; needs Chrome, skips cleanly without)

cd frontend && npm test                    # vitest (frontend i18n suite)
cd frontend && npm run build               # vite build → frontend/dist
```

`frontend/dist/` and `Gemfile.lock` are gitignored. `frontend/dist/` must exist for the SPA generator; the rake gate audits the generated site when Chrome is present. The rake CI does NOT build the frontend — a green CI says nothing about the SPA; run `npm ci && npm run build` locally to verify frontend changes.

## Architecture

- **`Lutaml::Openapi.parse`** stores the document **verbatim** — every parsed section is kept exactly as the source carried it (3.0 dialects included), so both wire serializations (`to_json`, `to_hash`) round-trip losslessly with no emit-time transform. `source_dialect` tracks the frontend used.
- **`Document#schemas`** is the typed view: it materializes `Lutaml::Jsonschema::Schema` models, applying `Oas30.normalize` per schema for 3.0 sources (nullable → null-union, exclusive bounds folded). That view is the only place the 3.0 frontend runs.
- **`Oas30`** normalizes 3.0 schema nodes into the 3.1 shape as a pure hash walk. There is no denormalization — do not add emit-time transforms; losslessness is structural.
- Unmapped root keys (vendor `x-*`, stray sections like `definitions`) ride the `extensions` catch-all and re-emit verbatim.
- **`CorpusAudit`** (lib/lutaml/openapi/corpus_audit.rb) asserts the wire round trip for every fixture in `spec/fixtures/` — 19 OGC API OAS documents. New fixtures are picked up automatically; validate Gemfile changes with a local `bundle lock` before shipping.
- **`Spa`** inlines `frontend/dist` with `window.OPENAPI_DATA` into a standalone `index.html`; dist enters the gem only at release time (the release train builds it).

## CI/release

- `.github/workflows/rake.yml` builds the frontend (`after-setup-ruby`) so green lanes validate the SPA.
- `release.yml` is self-contained (RubyGems Trusted Publishing is registered against THIS repo's workflow): dispatch with `next_version=patch|minor|major|x.y.z`. It bumps the version, builds the dist, publishes, and tags.

## Frontend

- All UI strings flow through the typed catalog `frontend/src/i18n/messages.ts` (`en` + `ar`); a missing key in a locale is a type error. The header locale switch mirrors `lang`/`dir` onto `<html>` (RTL without a second stylesheet); `?locale=ar` boots into a locale.
- Layout uses CSS logical properties; the axe audit gates both the LTR and Arabic RTL renders.
