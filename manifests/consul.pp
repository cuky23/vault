#start
#consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul -bind 127.0.0.1 -node=agent-one -config-dir=/etc/consul.d
#class to install vault from vault.io, with basic consul
class vault::consul (
	$active = undef,
    $consul_etc = "/etc/consul.d",
    $consul_opt = "/opt/consul",
	$consul_url = "https://releases.hashicorp.com/consul/0.7.5/consul_0.7.5_linux_amd64.zip",
	$consul_url_web_ui = "https://releases.hashicorp.com/consul/0.7.5/consul_0.7.5_web_ui.zip",
	$local_bin_dir = "/usr/local/bin",
	$download_dir = "/usr/tmp"
	) {
	if $active == true {
		notify{"vault::consul ":}
		exec{"wget_consul": 
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],		
			command => "wget $consul_url -O consul.zip",
			cwd => "$download_dir",
			creates => "$download_dir/consul.zip"
		}
		->
		exec{"unzip_install_consul": 
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],		
			command => "unzip consul.zip; chmod +x consul ; mv -f consul $local_bin_dir/consul",
			cwd => "$download_dir",
			creates => "$local_bin_dir/consul"
		}
		->
		exec{"wget_consul_web_ui": 
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],		
			command => "wget $consul_url_web_ui -O consul_web_ui.zip",
			cwd => "$download_dir",
			creates => "$download_dir/consul_web_ui.zip"
		}
		->
		exec{"unzip_consul_web_ui": 
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],		
			command => "mkdir -p ${download_dir}/dist ; mkdir -p /var/lib/consul ; cd dist ;unzip ../consul_web_ui.zip",
			cwd => "$download_dir",
			creates => "${download_dir}/dist"
		}
		->
		exec{"install_consul_web_ui": 
			path => ["/bin","/sbin","/usr/sbin","/usr/bin/","/usr/local/sbin","/usr/local/bin"],		
			command => "sudo mkdir -p ${consul_opt} ;sudo mv -f dist/ $consul_opt",
			cwd => "$download_dir",
			creates => "${consul_opt}/dist"
		}
		file{"${consul_etc}":
			ensure => directory,
		}
		->
		file{"${consul_etc}/consul.json":
			content => template("vault/consul/consul.json.erb"),
			ensure => present,
		}
		->
		#contrib el6 init script credit to https://github.com/samdunne/consul-centos-packer/blob/master/scripts/consul/consul.init
		file{"/etc/init.d/consul":
			content => template("vault/consul/init/consul.init.erb"),
			ensure => present,
			mode => "0755" ,
		}
		->
		#systemd el7 stuff
		exec{"systemctl_enable_consul":
			command => "sudo systemctl enable consul"
		}
		->
		exec{"systemctl_start_consul":
			command => "sudo systemctl start consul"
		}
		->
		service {"consul":
			ensure => "running"
		}
	} else {
		notify{"not active vault::consul":}
	}
}