require 'rspec/core/rake_task'
require 'bundler/gem_tasks'# Default directory to look in is `/spec`

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob("spec/**/*_spec.rb")
  t.rspec_opts = "--format documentation"
end

task :default => :spec