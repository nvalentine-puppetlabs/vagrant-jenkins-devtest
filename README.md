# vagrant-jenkins-devetest

You'll need to have downloaded and installed the following:
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](http://vagrantup.com/downloads.html)

For additional dependencies and setup see the Usage section below.

I highly recommend you look at [rbenv](https://github.com/sstephenson/rbenv) for managing your 
account's Ruby environment in a manner which is as sane as possible. The environment relies on
librarian-puppet which currently requires no later than Ruby 1.9.x. rbenv can help you
manage your Ruby versions and associated gems.

# Usage
Keep in mind this repo is a skeleton module so we are going to clone it, name it appropriately,
and then change the remote origin so we can push the module-specific version of the repo somewhere
where others may use it. In the example below we are creating a Puppet module called 'mymodule'

```sh-session
$ git clone git@<gitserver>:<git namespace>/<git repo> ./devtest-puppet-mymodule
$ cd devtest-puppet-mymodule
$ git remote set-url origin git@<gitserver>:<git namespace>/devtest-puppet-mymodule
```

Assuming you have either rbenv installed:

```sh-session
$ gem install bundler
$ bundle install && rbenv rehash
```
To check whether or not your system has all of the dependencies necessary to run the Vagrant environments:

```sh-session
$ rake deps
Checking environment dependencies...
...
Congratulations! Everything looks a-ok.
```

If the above step fails, unless the output tells you to do something differently, I recommend running:

```sh-session
$ rake setup
$ rake deps
```

## Populating the environment with the desired Puppet modules
The following command will use librarian-puppet to deploy the modules specified
in puppet/Puppetfile into your puppet/modules directory. 

```sh-session
$ rake modules
```

An examples Puppetfile, for instance for testing Presto Puppet module, might look something like this:

```yaml
forge 'https://forge.puppetlabs.com'

mod 'puppetlabs/stdlib', '3.2.1'
mod 'puppetlabs/postgresql', '3.3.3'
mod 'puppetlabs/inifile', '1.0.3'

mod 'puppetlabs/apache',
  :git => 'git@git.vchslabs.vmware.com:vchs/puppetlabs-apache',
  :ref => 'master'
```

At this point you are ready to go into puppet/modules and start creating feature branches
for development of your Puppet modules. 

__WARNING: Once you start development on your feature branches you DO NOT want to run
'rake modules' again or you will almost certainly lose the work you have done on the Puppet
modules as librarian-puppet will attempt to completely rebuild the module directory!__

## Starting your test VM
Vagrant will automagically create the VM, start the VM, and install the Puppet Enterprise
agent via the following command:

```sh-session
$ vagrant up
```

The PE agent install can take a few minutes due to needing to pull the PE tarball down
from the Internet so I recommend taking a snapshot after a successful 'vagrant up':

```sh-session
$ vagrant snapshot take fresh
```

You can take multiple snaphots as you are doing testing and can restore to the appropriate
snapshot with the 'vagrant snapshot list' and 'vagrant snapshot go <snapshot name>' commands.

To connect login to the VM:

```sh-session
$ vagrant ssh
```

## Running Puppet apply to test your new module code
In the spawned VM, you can run 'puppet apply' against the smoketest scripts for your modules:

```sh-session
$ sudo su -
# puppet apply --modulepath=/vagrant/puppet/modules /vagrant/puppet/modules/<your module>/tests/init.pp --debug
```

Note that the above command can be used to do multiple Puppet runs over a long-running VM. If you'd like to
test on a fresh OS you rebuild the VM by logging out of the VM and:

```sh-session
$ vagrant destroy -f
$ vagrant up
$ vagrant ssh
...
```

It takes some time to rebuild the VM so you'll want to minimize the number of fresh rebuild cycles. Also, if you
find yourself doing a lot of VM rebuilds then it is time to start investigating the following technologies:

### For local testing
* [rspec](http://rspec.info/)
* [beaker-rspec](https://github.com/puppetlabs/beaker-rspec)

### For centralized automated testing
* some form of [CI system]() 
  * [Jenkins](http://jenkinsci.org) is the most popular onsite solution.
  * [TravisCI](http://travisci.org) is a good place to start for cloud-base CI through most find they outgrow it quickly.
