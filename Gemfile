# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rake", "~> 13.0"
gem "rspec", "~> 3.0"
gem "rubocop", "~> 1.21"
gem "rubocop-performance", "~> 1.0"

# The engine's marshal-route strict-duplicate-keys scan (active whenever
# json >= 3) false-flags valid documents with repeated array elements —
# leptris/yeptris-ruby#333, present in every marshal engine since at
# least 0.6.36. Keep json 2 in CI until the scan is fixed; the gemspec
# stays unconstrained.
gem "json", "< 3"
