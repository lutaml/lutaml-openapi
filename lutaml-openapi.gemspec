# frozen_string_literal: true

require_relative "lib/lutaml/openapi/version"

Gem::Specification.new do |spec|
  spec.name = "lutaml-openapi"
  spec.version = Lutaml::Openapi::VERSION
  spec.authors = ["Ribose Inc."]
  spec.email = ["open.source@ribose.com"]

  spec.summary = "OpenAPI 3.0/3.1 as a lossless lutaml-model"
  spec.description = "Parse OpenAPI 3.0/3.1 documents into lossless " \
                     "LutaML model objects; the model layer for " \
                     "model-based OpenAPI standards"
  spec.homepage = "https://github.com/lutaml/lutaml-openapi"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.license = "BSD-2-Clause"

  gemspec_file = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__,
                                             err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec_file) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/
                          .rubocop.yml])
    end
  end.concat(Dir.glob("frontend/dist/*"))
  spec.require_paths = ["lib"]

  spec.add_dependency "json"
  spec.add_dependency "lutaml-jsonschema", "~> 0.1.25"
  spec.add_dependency "lutaml-model", "~> 0.8.122"
  # 0.6.50.0's marshal-engine strict-dup scan false-flags valid documents
  # on native-less lanes (leptris/yeptris-ruby#333, the #680 class)
  spec.add_dependency "yeptris", "~> 0.6.34", "!= 0.6.50.0"
end
