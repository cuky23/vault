#puppet module to install vault.io with a small amount of consul.io

I undertook writing it based on the good work from here 
"https://dunne.io/vault-and-self-signed-ssl-certificates#disqus_thread"

With bits from https://github.com/samdunne/consul-centos-packer/tree/master/scripts/consul, as why revent the wheel.  the init script for el6 works fine on el7

This puppet module will install a Self Sign CA for vault and configure linux to use it.  Tested on Centos7.3
Seems to be a bug aroung the CA being seen on Centos7.3 I have put a helpper script to add the CERT via cat if it doesnt exist. /tmp/update_ca.sh

Todo : vault init script isnt working 100% 

checking things worked and vault/consul are available.

http://localhost:8500

Should load a nice GUI showings services in dc1

Out of scope :: using vault.

```
vault init 
```
First run will display five keys and a Root Token.  make a note of them, you will need them to unseal
if vault is sealed , you need to feed it three of the five keys it displayed when you ran vault init.
```
vault unseal <key1>
Key (will be hidden): 
Sealed: true
Key Shares: 5
Key Threshold: 3
Unseal Progress: 1
Unseal Nonce: HEXKEY

vault unseal <key2>
Key (will be hidden): 
Sealed: true
Key Shares: 5
Key Threshold: 3
Unseal Progress: 2
Unseal Nonce: HEXKEY

vault unseal <key3>
Key (will be hidden): 
Sealed: false
Key Shares: 5
Key Threshold: 3
Unseal Progress: 0
Unseal Nonce: 
```
