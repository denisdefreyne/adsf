# frozen_string_literal: true

require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop)

# TODO: Replace this with Bundler.with_unbundled_env
def with_unbundled_env
  if Bundler.respond_to?(:with_unbundled_env)
    Bundler.with_unbundled_env { yield }
  else
    Bundler.with_clean_env { yield }
  end
end

def sub_sh(dir, cmd)
  with_unbundled_env do
    Dir.chdir(dir) do
      puts "(in #{Dir.getwd})"
      sh(cmd)
    end
  end
end

namespace :adsf do
  task(:test) { sub_sh('adsf', 'bundle exec rake test') }
  task(:gem) { sub_sh('adsf', 'bundle exec rake gem') }
end

namespace :adsf_live do
  task(:test) { sub_sh('adsf-live', 'bundle exec rake test') }
  task(:gem) { sub_sh('adsf-live', 'bundle exec rake gem') }
end

task test: %i[adsf:test adsf_live:test gem]
task gem: %i[adsf:gem adsf_live:gem]

task default: %i[test rubocop]
