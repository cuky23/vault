#if versioncmp($::puppetversion,'3.6.1') >= 0 {

  $allow_virtual_packages = hiera('allow_virtual_packages',false)

  Package {
    allow_virtual => $allow_virtual_packages,
  }
#}

include base
notify { 'my_message':
  message => hiera('my_message'),
}