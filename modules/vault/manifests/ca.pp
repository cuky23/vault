#class to install vault from vault.io, with basic consul
class vault::ca (
	$active = undef,
	$keysize = "2048",
	$ca_key = "rootCA.key",
	$ca_crt = "rootCA.crt",
	$ca_days = "3650",
	$ca_C = "GB" ,
	$ca_o = "127.0.0.1" ,
	$ca_cn = "127.0.0.1",
	$ca_trust_dir = "/etc/pki/ca-trust",
    $ca_trust_conf = "vault-ca.conf",
	$serialfile_counter = "000a",
	$rootcertificate = "/etc/pki/ca-trust/source/anchors/ca.pem",
	$private_dir = "/etc/pki/tls/private",
	$certs_dir = "/etc/pki/tls/certs",
	$subjectaltname = "IP:127.0.0.1",
	$default_md = "sha256",
	$default_days = "365",
	$local_bin_dir = "/usr/local/bin",
	$download_dir = "/usr/tmp"
	) {
	if $active == true {
		notify{"vault::ca active":}
		#step 1 Generate a root certificate :: create CA to trust
		exec{"update-ca-trust_enable":
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],
			command => "sudo update-ca-trust enable"	

		}
		->
		exec{"make_${private_dir}/$ca_key":
			path => "/bin:/sbin:/usr/sbin:/usr/bin/:/usr/local/sbin:/usr/local/bin",
			command => "openssl genrsa -out ${private_dir}/${ca_key} ${keysize} ; chmod 0600 ${private_dir}/${ca_key}",
			cwd => "$private_dir",
			creates => "${private_dir}/${ca_key}"
		}
		->
		exec{"make_${certs_dir}/$ca_crt":
			path => "/bin:/sbin:/usr/sbin:/usr/bin/:/usr/local/sbin:/usr/local/bin",
			command => "openssl req -x509 -sha256 -new -nodes -days $ca_days -key ${private_dir}/${ca_key} -out ${certs_dir}/${ca_crt} -subj \"/C=${ca_C}/O=${ca_o}/CN=$ca_cn\"",
			cwd => "$certs_dir",
			creates => "${certs_dir}/${ca_crt}"
		}
		->		
		exec{"make_/etc/pki/ca-trust/source/anchors/ca.crt":
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],
			command => "sudo cp ${certs_dir}/${ca_crt} $rootcertificate ",
			cwd => "/etc/pki/ca-trust/source/anchors",
			#creates => "$rootcertificate"
		}
		->
		exec{"update-ca-trust_extract":
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],
			command => "sudo update-ca-trust extract"	
		}
		->
		file {"/tmp/update_ca.sh":
			ensure => present,
			content => template("vault/ca/update_ca.sh.erb"),
			mode => "0755"
		}
		->
		exec{"run shell_ca_bundle":
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],
			command => "/tmp/update_ca.sh",
		}
		->
		exec{"mkdir_${certs_dir}":
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],
			command => "mkdir -p ${certs_dir}"	
		}
		->
		exec{"update-ca-trust_enable_final_pass":
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],
			command => "sudo update-ca-trust enable"	

		}
		->
		file {"${certs_dir}/serialfile":
			content => "$serialfile_counter"
		}
		->
		file {"${certs_dir}/certindex":
			ensure => present
		}
	}
}