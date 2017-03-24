# == Class: base
# Base class 
# == Authors:
# Stephen Cooke@demo.co.uk
#
class base (
#SET UP GLOBALS here look at hiera
  $platform       = "demo",
  $timezone   = "Europe/London",
  $debug           = undef
  ){
    include stdlib
    stage { 'first': 
          before => Stage['main'],
    }
    stage { 'last': 
         before => Stage['end'],
    }
    stage { 'end': }
    
    Stage['main'] -> Stage['last'] -> Stage['end']

    class {'vault': stage => last}
}



