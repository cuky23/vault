#class to install vault from vault.io, with basic consul
class vault (
	$active = undef,
	) {
	if $active == true {
		notify{"vault main":}
		->
        class{"vault::ca": active => true}	
        ->
        class{"vault::consul": active => true}	
        ->
        class{"vault::vaultconf": active => true}

	
	}
}