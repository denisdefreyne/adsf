require 'adsf'
require 'rubocop/rake_task'

desc 'Run all tests'
task :test do
  $LOAD_PATH.unshift(__dir__)

  require 'minitest/autorun'
  MiniTest.autorun

  test_files = Dir['test/**/test_*.rb']
  test_files.each { |f| require f }
end

RuboCop::RakeTask.new(:rubocop)

task default: %i[test rubocop]
