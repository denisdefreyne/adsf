require 'minitest/unit'

desc 'Run all tests'
task :test do
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/..'))

  MiniTest::Unit.autorun

  test_files = Dir["test/**/test_*.rb"]
  test_files.each { |f| require f }
end
