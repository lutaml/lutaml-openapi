# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe Lutaml::Openapi::Document do
  def fixture(name)
    File.read(File.expand_path("fixtures/#{name}", __dir__))
  end

  def deep_match?(expected, actual)
    return container_pair?(expected, actual) if
      expected.is_a?(Hash) || expected.is_a?(Array)

    expected == actual
  end

  def container_pair?(expected, actual)
    if expected.is_a?(Hash)
      hash_pair?(expected, actual)
    else
      array_pair?(expected, actual)
    end
  end

  def hash_pair?(expected, actual)
    # key order is not semantic (lutaml-model emits in mapping order —
    # semantically lossless, not byte-identical, per #993's law)
    return false unless actual.is_a?(Hash) &&
      expected.keys.sort == actual.keys.sort

    expected.all? { |key, value| deep_match?(value, actual[key]) }
  end

  def array_pair?(expected, actual)
    return false unless actual.is_a?(Array) && expected.size == actual.size

    expected.each_with_index.all? do |value, index|
      deep_match?(value, actual[index])
    end
  end

  it "parses a minimal 3.1 document" do
    doc = described_class.from_json(
      JSON.generate({ "openapi" => "3.1.0", "info" => { "title" => "T" } }),
    )

    expect(doc.openapi).to eq("3.1.0")
    expect(doc.info).to eq("title" => "T")
  end

  it "round-trips unknown keywords verbatim" do
    json = JSON.generate({
                           "openapi" => "3.1.0",
                           "x-vendor" => { "deep" => [1, 2] },
                           "info" => { "title" => "T" },
                         })
    doc = described_class.from_json(json)

    expect(doc.extensions).to eq("x-vendor" => { "deep" => [1, 2] })
    expect(JSON.parse(doc.to_json)).to include("x-vendor" => { "deep" => [1,
                                                                          2] })
  end

  describe "the OGC API corpus" do
    corpus = Dir.children(File.expand_path("fixtures", __dir__)).sort

    it "vendors the full audited corpus" do
      # the 17 OAS documents the metanorma/ogcapi-* fork audit verifies,
      # plus both tiles variants and the 3.0/3.1 EDR bundles
      expect(corpus.size).to eq(19)
    end

    corpus.each do |tag|
      it "round-trips #{tag} losslessly" do
        source = fixture(tag)
        original = JSON.parse(
          JSON.generate(Lutaml::Openapi.parse_raw(source)),
        )

        # the wire is the losslessness contract: mapped sections re-emit
        # in dialect shape, the extensions catch-all verbatim
        emitted = JSON.parse(Lutaml::Openapi.parse(source).to_json)

        diverged = "round trip diverged for #{tag}"
        expect(deep_match?(emitted, original)).to be(true), diverged
      end
    end

    it "materializes components.schemas as lutaml-jsonschema Schemas" do
      doc = Lutaml::Openapi.parse(fixture("ogcapi-features-1-oas31.yaml"))

      expect(doc.schemas.size).to eq(21)
      expect(doc.schemas["exception"]).to be_a(Lutaml::Jsonschema::Schema)
      exception = doc.schemas["exception"]
      expect(exception.property_entries.map(&:name)).to include("type",
                                                                "status")
    end

    it "normalizes the 3.0 document and keeps its dialect" do
      doc = Lutaml::Openapi.parse(fixture("ogcapi-features-1-oas30.yaml"))

      expect(doc.source_dialect).to eq("3.0")
      expect(doc.openapi).to eq("3.0.4")
    end
  end

  describe "the 3.0 frontend" do
    it "normalizes nullable and boolean exclusivity into the 3.1 shape" do
      doc = Lutaml::Openapi.parse(<<~YAML)
        openapi: 3.0.3
        components:
          schemas:
            thing:
              type: object
              properties:
                name:
                  type: string
                  nullable: true
                count:
                  type: integer
                  minimum: 5
                  exclusiveMinimum: true
      YAML

      name = doc.schemas["thing"].property_entries.find { |p| p.name == "name" }
      count = doc.schemas["thing"].property_entries.find do |p|
        p.name == "count"
      end
      expect(name.schema.types).to eq(%w[string null])
      expect(count.schema.exclusive_minimum).to eq(5)
      expect(count.schema.minimum).to be_nil
    end

    it "keeps 3.0 semantics verbatim on the hash form" do
      doc = Lutaml::Openapi.parse(<<~YAML)
        openapi: 3.0.3
        components:
          schemas:
            thing:
              type: object
              properties:
                name:
                  type: string
                  nullable: true
                count:
                  type: integer
                  minimum: 5
                  exclusiveMinimum: true
      YAML

      props = doc.to_hash.dig("components", "schemas", "thing", "properties")
      expect(props["name"]).to eq("type" => "string", "nullable" => true)
      expect(props["count"]).to eq(
        "type" => "integer", "minimum" => 5, "exclusiveMinimum" => true,
      )
    end
  end
end
