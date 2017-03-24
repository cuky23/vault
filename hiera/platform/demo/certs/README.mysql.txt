
#Create CA Certificates
#generate CA KEY 
openssl genrsa 2048 >/etc/pki/tls/private/rs_hosting.ca.mysql.key
#generate CA CRT for 10 years
openssl req -new -x509 -nodes -days 3650 -key /etc/pki/tls/private/rs_hosting.ca.mysql.key >/etc/pki/tls/certs/rs_hosting.ca.mysql.crt

#Create Server Certificates (CSR/CRT)
openssl req -newkey rsa:2048 -days 3650 -nodes \
-keyout /etc/pki/tls/private/rs_hosting.server.mysql.key \
-subj '/DC=com/DC=cuky/CN=server' >/etc/pki/tls/certs/rs_hosting.server.mysql.csr
# server(selfsign) Sign the CSR using the selfsign CA
openssl x509 -req -in /etc/pki/tls/certs/rs_hosting.server.mysql.csr \
-days 3650 -CA /etc/pki/tls/certs/rs_hosting.ca.mysql.crt \
-CAkey /etc/pki/tls/private/rs_hosting.ca.mysql.key  \
-set_serial 01 >/etc/pki/tls/certs/rs_hosting.server.mysql.crt

#Create Client Certificates
openssl req -newkey rsa:2048 -days 3650 -nodes \
-keyout /etc/pki/tls/private/rs_hosting.client.mysql.key \
-subj '/DC=com/DC=cuky/CN=client' >/etc/pki/tls/certs/rs_hosting.client.mysql.csr

# client (selfsign) Sign the CSR using the selfsign CA
openssl x509 -req -in /etc/pki/tls/certs/rs_hosting.client.mysql.csr \
-days 3650 -CA /etc/pki/tls/certs/rs_hosting.ca.mysql.crt \
-CAkey /etc/pki/tls/private/rs_hosting.ca.mysql.key  \
-set_serial 01 >/etc/pki/tls/certs/rs_hosting.client.mysql.crt
	
#now add the settings to MYSQL ( my.cnf.d/server.cnf )
[mysqld]
ssl-ca		= /etc/pki/tls/certs/rs_hosting.ca.mysql.crt
ssl-cert	= /etc/pki/tls/certs/rs_hosting.server.mysql.crt
ssl-key		= /etc/pki/tls/private/rs_hosting.server.mysql.key 

#review this to setup the replication to use SSL
#https://dev.mysql.com/doc/refman/5.1/en/replication-solutions-ssl.html
mysql > stop slave ;
mysql > CHANGE MASTER TO MASTER_HOST='192.168.5.111', MASTER_USER='repl_db', 
MASTER_PASSWORD='PASSWORD',MASTER_SSL=1, 
MASTER_SSL_CERT = '/etc/pki/tls/certs/rs_hosting.client.mysql.crt',
MASTER_SSL_KEY = '/etc/pki/tls/private/rs_hosting.client.mysql.key';
mysql > start slave ;
