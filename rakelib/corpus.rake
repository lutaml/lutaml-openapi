# frozen_string_literal: true

require "lutaml/openapi/corpus_audit"

namespace :corpus do
  desc "Audit the vendored OGC corpus: lossless round-trip + coverage matrix"
  task :audit do
    rows = Lutaml::Openapi::CorpusAudit.matrix
    format = "%-46s %-7s lossless=%-5s schemas=%-4d " \
             "documented=%-4d ops=%-3d ops_text=%d"
    rows.each do |r|
      puts format(format, r[:file], r[:openapi], r[:lossless], r[:schemas],
                  r[:schemas_documented], r[:operations],
                  r[:operations_with_text])
    end
    failures = rows.reject { |r| r[:lossless] }
    unless failures.empty?
      abort "corpus:audit: lossless round-trip failed for " \
            "#{failures.map { |r| r[:file] }.join(', ')}"
    end
  end
end

namespace :frontend do
  File.expand_path("frontend/dist", __dir__)
  node_modules = File.expand_path("frontend/node_modules", __dir__)

  task :install do
    unless File.directory?(node_modules)
      Dir.chdir("frontend") do
        sh "npm install"
      end
    end
  end

  task build: :install do
    Dir.chdir("frontend") { sh "npm run build" }
  end
end
