begin
  require 'os'
  require 'ptools'
  require 'colored'
rescue LoadError => e
  puts "Error during requires: \t#{e.message}"
  abort "You may be able to fix this problem by running 'bundle'.".red
end

task :default => 'deps'

necessary_programs = %w(VirtualBox vagrant puppet)
necessary_plugins = %w(oscar vagrant-vbox-snapshot vagrant-pe_build)
blacklist_plugins = %w(vagrant-vmware-fusion vagrant-vmware-workstation)
necessary_gems = %w(librarian-puppet)
ruby_major = '1.9'

desc 'Check for the environment dependencies'
task :deps do
  puts 'Checking environment dependencies...'

  printf "Is this a POSIX OS?..."
  unless OS.posix?
    abort 'Sorry, you need to be running Linux or OSX to use this Vagrant environment!'.red
  end
  puts "OK"
 
  necessary_programs.each do |prog| 
    printf "Checking for %s...", prog
    unless File.which(prog)
      abort "\nSorry but I didn't find require program \'#{prog}\' in your PATH.\n".red
    end
    puts "OK"
  end

  necessary_plugins.each do |plugin|
    printf "Checking for vagrant plugin %s...", plugin
    unless %x{vagrant plugin list}.include? plugin
      puts "\nSorry, I wasn't able to find the Vagrant plugin \'#{plugin}\' on your system."
      abort "You may be able to fix this by running 'rake setup\'.\n".red
    end
    puts "OK"
  end

  blacklist_plugins.each do |plugin|
    printf "Checking for absence of vagrant plugin %s...", plugin
    if %x{vagrant plugin list}.include? plugin
      puts "\nSorry, but #{plugin} is incompatible with this environment.".red
      abort "\nYou may be able to rectify this situation via \"vagrant plugin uninstall #{plugin}\".".red
    end
    puts "OK"
  end

  unless %x{ruby --version}.include? ruby_major
    abort "Sorry but Ruby version #{ruby_major}.x is required for librarian-puppet.".red
  end

  necessary_gems.each do |gem|
    printf "Checking for Ruby gem %s...", gem
    unless system("gem list --local -q --no-versions --no-details #{gem} | egrep '^#{gem}$' > /dev/null 2>&1")
      puts "\nSorry, I wasn't able to find the \'#{gem}\' gem on your system.".red
      abort "You may be able to fix this by running \'gem install #{gem}\'.\n".red
    end
    puts "OK"
  end

  printf "Checking for additional gems via 'bundle check'..."
  unless %x{bundle check}
    abort ''
  end

  puts "OK"

  puts "\n" 
  puts '*' * 80
  puts "Congratulations! Everything looks a-ok."
  puts '*' * 80
  puts "\n"
end

desc 'Install the necessary Vagrant plugins'
task :setup do
  necessary_plugins.each do |plugin|
    unless system("vagrant plugin install #{plugin} --verbose")
      abort "Install of #{plugin} failed. Exiting...".red
    end
  end

  necessary_gems.each do |gem|
    unless system("gem install #{gem}")
      abort "Install of #{gem} failed. Exiting...".red
    end
  end

  unless %x{bundle check} 
    system('bundle install')
  end

end

desc 'Build out the modules directory for devtest'
task :modules do
  puts "Building out Puppet module directory..."
  unless system('cd puppet && librarian-puppet install --verbose')
    abort 'Failed to build out Puppet module directory. Exiting...'.red
  end
  puts "OK"
end
