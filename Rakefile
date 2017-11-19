require 'rubocop/rake_task'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.test_files = Dir['test/**/test_*.rb']
  t.libs << 'test'
  t.verbose = false
end

RuboCop::RakeTask.new(:rubocop)

task default: %i[test rubocop]
