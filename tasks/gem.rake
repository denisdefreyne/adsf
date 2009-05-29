require 'adsf/package'

require 'rubygems/package_task'

namespace :gem do

  package_task = Gem::PackageTask.new(Adsf::Package.instance.gem_spec) { |pkg| }

  desc 'Install the gem'
  task :install => [ :package ] do
    sh %{gem install pkg/#{package_task.name}-#{Adsf::VERSION}}
  end

  desc 'Uninstall the gem'
  task :uninstall do
    sh %{gem uninstall #{package_task.name}}
  end

end

desc 'Alias for gem:package'
task :gem => [ :'gem:package' ]
