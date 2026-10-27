# frozen_string_literal: true

require "spec_helper"
require "lutaml/openapi/spa"

RSpec.describe Lutaml::Openapi::Spa do
  before do
    unless File.exist?(File.join(Lutaml::Openapi::Spa::DIST, "app.iife.js"))
      skip "frontend/dist not built — run rake frontend:build"
    end
  end

  it "generates a single-file site with the document data inlined" do
    doc = Lutaml::Openapi.parse(File.read(
                                  File.join(Lutaml::Openapi::CorpusAudit::FIXTURES,
                                            "ogcapi-features-1-oas31.yaml"),
                                ))
    html = described_class.generate(doc)
    title = "Building Blocks specified in OGC API - Features - Part 1: Core"
    expect(html).to include("<title>#{title}</title>")
    expect(html).to include("window.OPENAPI_DATA = ")
    expect(html).to include("window.OPENAPI_DATA")
    expect(html).to include('<div id="app">')
  end

  it "escapes the title" do
    doc = Lutaml::Openapi.parse(<<~YAML)
      openapi: 3.1.0
      info:
        title: A <script>alert(1)</script> title
    YAML
    html = described_class.generate(doc)
    expect(html).not_to include("<script>alert(1)")
    # escape() escapes & and <; ">" needs no escaping in content
    row = "&lt;script&gt;alert(1)&lt;/script&gt;".gsub("&gt;", ">")
    expect(html).to include(row)
  end
end
