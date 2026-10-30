# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop frontend:audit]

namespace :frontend do
  desc "Build the Vue frontend"
  task :build do
    Dir.chdir(File.expand_path("frontend", __dir__)) do
      sh "npm install"
      sh "npm run build"
    end
  end

  desc "axe-core accessibility audit of the generated SPA (needs Chrome)"
  task :audit do
    ruby "script/axe_audit"
  end
end
