## site.pp ##

# Force noop mode unless specified otherwise in hiera
$force_noop = hiera('force_noop')
unless false == $force_noop {
    notify { "Puppet noop safety latch is enable in site.pp": }
    noop()
}

# Allow hiera to assign classes
hiera_include('classes')
