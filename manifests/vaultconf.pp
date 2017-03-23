#class to install vault from vault.io, with basic consul
class vault::vaultconf (
	$active = undef,
	$keysize = "2048",
	$serialfile_counter = "000a",
	$rootcertificate = "/etc/pki/ca-trust/source/anchors/ca.pem",
	$private_dir = "/etc/pki/tls/private",
	$certs_dir = "/etc/pki/tls/certs",
    $subjectaltname = "IP:127.0.0.1",
	$default_md = "sha256",
	$default_days = "365",
	$vault_ssldir = "/var/lib/vault/ssl",
	$vault_cn = "127.0.0.1",
	$vault_csr = "vault.csr",
	$vault_key = "vault.key",
	$vault_crt = "vault.crt",
    $vault_etc = "/etc/vault.d",
    $vault_url = "https://releases.hashicorp.com/vault/0.7.0/vault_0.7.0_linux_amd64.zip",
	$local_bin_dir = "/usr/local/bin",
	$download_dir = "/usr/tmp",
	$ca_key = "rootCA.key",
	$ca_crt = "rootCA.crt",
	$ca_days = "3650",
	$ca_C = "GB" ,
	$ca_o = "127.0.0.1" ,
	$ca_cn = "127.0.0.1",
	$ca_trust_dir = "/etc/pki/ca-trust",
    $ca_trust_conf = "vault-ca.conf",
	) {
	if $active == true {
		#Step 2 Generate csr and key ::  Vault KEY AND CSR ( no selfy, can use own CA from above)
		file {"${certs_dir}/${ca_trust_conf}":
			ensure => present,
			content => template("vault/ca/${ca_trust_conf}.erb"),
		}
		->
		exec{"mkdir_${vault_ssldir}":
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],
			command => "mkdir -p ${vault_ssldir}"	
		}
		->
		exec{"make_${vault_ssldir}/vault.key":
			path => "/bin:/sbin:/usr/sbin:/usr/bin/:/usr/local/sbin:/usr/local/bin",
			command => "openssl genrsa -out vault.key ${keysize}",
			cwd => "$vault_ssldir",
			creates => "${vault_ssldir}/$vault_key"

		}
		->
		exec{"generate_csr_vault}":
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],
			command => "openssl req -new -key ${vault_ssldir}/$vault_key -nodes -out $vault_ssldir/$vault_csr  -subj \"/C=GB/O=${ca_o}/CN=${vault_cn}\"",
			cwd => "$vault_ssldir",
			creates => "$vault_ssldir/$vault_csr"
		}
		->
		# Step 3 Sign the CERT
		exec{"sign_vault_csr_create_crt": 
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],
			#'openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 500 -sha256'
			command => "openssl ca -batch -config ${certs_dir}/$ca_trust_conf -in ${vault_ssldir}/${vault_csr} -out ${vault_ssldir}/${vault_crt}",
			cwd => "${certs_dir}",
			creates => "$vault_ssldir/$vault_crt",
			require => File["${certs_dir}/${ca_trust_conf}"]

		}
		###############################################
		# next download vault
		->
		exec{"wget_vault": 
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],		
			command => "wget $vault_url -O vault.zip",
			cwd => "$download_dir",
			creates => "$download_dir/vault.zip"
		}
		->
		exec{"unzip_install_vault": 
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],		
			command => "unzip vault.zip; chmod +x vault ; mv -f vault $local_bin_dir/vault",
			cwd => "$download_dir",
			creates => "$local_bin_dir/vault"
		}
		->
		#vault config file
		exec{"mkdir_${vault_etc}":
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],
			command => "mkdir -p ${vault_etc}"	
		}
		->
		file{"${vault_etc}/configuration.json":
			content => template("vault/vault/configuration.json.erb"),
			ensure => present,
		}		
		->
		#contrib el6 init script credit to https://github.com/samdunne/consul-centos-packer/blob/master/scripts/consul/consul.init
		file{"/etc/init.d/vault":
			content => template("vault/vault/init/vault.init.erb"),
			ensure => present,
			mode => "0755" ,
		}
		->
		#systemd el7 stuff
		exec{"systemctl_enable_vault":
			command => "sudo systemctl enable vault"
		}
		->
		exec{"systemctl_start_vault":
			command => "sudo systemctl start vault"
		}
		->
		service {"vault":
			ensure => "running"
		}
	}
}