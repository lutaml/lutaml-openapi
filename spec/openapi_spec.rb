# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe Lutaml::Openapi::Document do
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
end
