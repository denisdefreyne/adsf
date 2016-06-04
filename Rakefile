require 'adsf'
require 'rubocop/rake_task'

desc 'Run all tests'
task :test do
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

  require 'minitest/autorun'
  MiniTest.autorun

  test_files = Dir['test/**/test_*.rb']
  test_files.each { |f| require f }
end

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options  = %w( --display-cop-names --format simple )
  task.patterns = ['lib/**/*.rb', 'spec/**/*.rb']
end

task default: [:test, :rubocop]
