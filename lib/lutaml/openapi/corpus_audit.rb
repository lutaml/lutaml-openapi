# frozen_string_literal: true

require "lutaml/openapi"

module Lutaml
  module Openapi
    # The metanorma-ogc#153 corpus audit as a repeatable task: parse
    # every vendored corpus fixture, assert the lossless round-trip,
    # report the description/summary coverage matrix.
    module CorpusAudit
      FIXTURES = File.expand_path("../../../spec/fixtures",
                                  __dir__)

      def self.files
        Dir.glob("#{FIXTURES}/*.{yaml,yml,json}")
      end

      def self.matrix
        files.map { |path| row(path) }
      end

      def self.row(path)
        doc = Lutaml::Openapi.parse(File.read(path))
        raw = doc.to_hash
        schema_stats = schema_stats(raw)
        { file: File.basename(path), openapi: raw["openapi"],
          lossless: lossless?(path, doc), **schema_stats }
      end

      def self.schema_stats(raw)
        schemas = raw.dig("components", "schemas") || {}
        documented = schemas.values.count do |s|
          s.is_a?(Hash) && s["description"].is_a?(String) &&
            !s["description"].strip.empty?
        end
        { schemas: schemas.size, schemas_documented: documented,
          **operation_stats(raw) }
      end

      def self.operation_stats(raw)
        operations = 0
        with_text = 0
        each_operation(raw) do |op|
          operations += 1
          text = op["summary"] || op["description"]
          with_text += 1 if text.is_a?(String) && !text.strip.empty?
        end
        { operations: operations, operations_with_text: with_text }
      end

      def self.each_operation(raw, &block)
        paths = raw["paths"] || {}
        paths.each_value do |item|
          next unless item.is_a?(Hash)

          yield_operations(item, &block)
        end
      end

      def self.yield_operations(item, &)
        item.each_value do |operation_entry|
          next unless operation?(operation_entry)

          yield operation_entry
        end
      end

      def self.operation?(operation_entry)
        operation_entry.is_a?(Hash) && operation_entry["responses"]
      end

      def self.lossless?(path, doc)
        raw = Lutaml::Openapi.parse_raw(File.read(path))
        # The model is JSON-keyed: YAML integer keys (unquoted response
        # codes) stringify through the pipeline, so compare against the
        # JSON-normalized raw. to_hash is the serialization contract:
        # 3.0 sources denormalize back on it. Hash == is deep and
        # key-order-insensitive.
        normalized = JSON.parse(JSON.generate(raw))
        doc.to_hash == normalized
      end
    end
  end
end
