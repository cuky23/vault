# -*- mode: ruby -*-
# vi: set ft=ruby :

@ui = Vagrant::UI::Colored.new

require 'yaml'

if File.exist?('box.yaml')
	@ui.info "Using box.yaml"
	box = YAML.load_file('box.yaml')
else
	@ui.info "Using DEFAULT_box.yaml"
	box = YAML.load_file('DEFAULT_box.yaml')
end	

VAGRANTFILE_API_VERSION = "2"
#Vagrant.require_version ">= 1.7.2"

#check for the env VAGRANT_PLATFORM
if ENV.has_key?('VAGRANT_PLATFORM') 
	
	platform = ENV['VAGRANT_PLATFORM']
	serversfilename = "#{platform}.servers.yaml"
else
	platform = "pism"
	serversfilename = "servers.yaml"

end 
if File.exist?("#{serversfilename}")
	@ui.info "Using #{serversfilename}"
	servers = YAML.load_file("#{serversfilename}")
else
	@ui.error "FORMAT FAILURE no #{serversfilename} found."
	abort('Please setup your servers.yaml from TEMPLATE_servers.yaml ')
end


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	#config.ssh.pty = true
	boxurl = 'centos6a'
	bootstrap = 'el6script'
	@ui.info "eyaml version"
	servers.each do |servers|
		config.vm.define servers["name"] do |srv|
			srv.vm.hostname = servers["hostname"]
			srv.vm.provider :managed do |managed, override|
				managed.server = servers["name"]
				override.nfs.functional = false
				override.vm.box = servers["box"]
				override.ssh.username = servers["user"]
				override.ssh.private_key_path = servers["keypath"]
				if servers.has_key?("port")
					override.ssh.port = servers["port"]
				else
					override.ssh.port = 22
				end
			end
			boxurl = servers["url"]
			#config.vm.box = servers["box"]
			#bootstrapping GRAB vbox detail from server.yaml
			if  servers.has_key?("bootstrap")
					bootstrap ="#{servers["bootstrap"]}"
			else
					bootstrap ="el6script"
			end
			if  servers.has_key?("platform")
				platform ="#{servers["platform"]}"
			end
			#file magic to push bootstrap/el6script at host then run it
			config.vm.provision "file", source: "./bootstrap/#{bootstrap}", destination: "/tmp/#{bootstrap}"
			@ui.info "Using BOOTSTRAP #{bootstrap}"
			config.vm.provision "shell",  inline: "/bin/bash /tmp/#{bootstrap}"
			#chk the os to see who to use to mount www as

			config.vm.provision "puppet" do |puppet|
				puppet.hiera_config_path = "hiera.yaml"
				puppet.module_path = "modules"
				puppet.options = "--parser future"
				puppet.facter = { "platform" => "#{platform}" }
			end
			@ui.info "platform is set as #{platform}"
			config.vm.provision "shell", inline: "ip a | grep inet | grep -e eth -e br"
		end
	end 
end
