# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

## [0.1.3] - 2026-10-31

- Round-trip the full OGC corpus on the wire: all 19 vendored fixtures
  (processes and connected-systems included) parse → to_json → parse
  losslessly; documents are stored verbatim and the 3.0 frontend
  applies only in the typed schema view
- Frontend parity with lutaml-jsonschema's SPA: typed en+ar string
  catalog with locale switch, RTL layout, axe AA audit in the default
  rake gate, vitest suite, CI frontend build
- Floor yeptris at the fixed `~> 0.6.51` line (marshal strict-dup
  false-positive fixed, yeptris-ruby#333)
- Backfill the changelog for 0.1.0–0.1.2; frontend dev toolchain bumped
  past the vulnerable ranges

## [0.1.2] - 2026-10-28

- Ship the SPA dist through the release train; self-contained in-repo
  release workflow (RubyGems Trusted Publishing)
- Frontend dev toolchain bumped past the vulnerable ranges
  (vite 8, vitest 5, @vitejs/plugin-vue 6)

## [0.1.1] - 2026-10-25

- Add the records + tiles corpus goldens

## [0.1.0] - 2026-10-24

- Initial release: lossless OpenAPI 3.0/3.1 model on lutaml-model,
  3.0→3.1 normalization, M2 single-file SPA documentation site,
  OGC corpus verification
