#!/bin/bash

#Usernames
DB_USER='mysql_user'
DB_NAME='wordpress_db'
SITE_URL='https://www.bearmahoney.xyz'

#Dependencies and updates
enable_php7='amazon-linux-extras enable php7.4'
clean_metadata='yum clean metadata -y'
yum_update='yum update -y'
install_dependencies='yum install jq php-cli php-pdo php-fpm php-json php-mysqlnd httpd mod_ssl -y'

#Wordpress files
get_wordpress='wget https://wordpress.org/latest.tar.gz' 
decompress_wordpress='tar -xzf latest.tar.gz'
copy_sample='cp wordpress/wp-config-sample.php wordpress/wp-config.php'
copy_html_files='cp -r wordpress/* /var/www/html/'

#Permission commands
chown_www='chown -R apache:apache /var/www'

#System commands
httpd_start='systemctl start httpd'

log() {
	echo $(date "+%y-%m-%d %H:%M") "$1" "$2"
}

fix_wordpress_config() {
	local password=$(aws secretsmanager get-secret-value --secret-id db_secret --region us-east-1 | jq .SecretString | tr -d '"')
	local rds_endpoint=$(aws rds describe-db-instances --region us-east-1 | jq '.DBInstances[ ].Endpoint.Address' | tr -d '"')
	local site_config="define( 'WP_HOME', '$SITE_URL' );\ndefine( 'WP_SITEURL', '$SITE_URL' );"
	local config_file='/var/www/html/wp-config.php'

	sed -i "s/database_name_here/$DB_NAME/g" $config_file
	sed -i "s/username_here/$DB_USER/g"  $config_file
	sed -i "s/password_here/$password/g" $config_file
	sed -i "s/localhost/$rds_endpoint/g" $config_file
	awk -v site_config="$site_config" 'NR==2 {print site_config} 1' /var/www/html/wp-config.php > /tmp/tmp_cfg && mv -f /tmp/tmp_cfg /var/www/html/wp-config.php
}

create_health_check_file() {
	echo "ok" > /var/www/html/healthy
}

create_crontabs() {
	echo "0 2 14 * * root $(command -v bash) -c '/bin/yum update --security -y && /usr/sbin/shutdown -r'" > /etc/cron.d/monthly_system_update
}

create_ssl_config() {
	mkdir -p /etc/ssl/certs/
	local private_key_file='/etc/ssl/certs/web_private.pem'
	local cert_file='/etc/ssl/certs/web_certificate.crt'
	local cert_file_contents=$(aws iam get-server-certificate --server-certificate-name webserver_cert --region us-east-1 | jq .ServerCertificate.CertificateBody | tr -d '"')
	local private_key_file_contents=$(aws secretsmanager get-secret-value --secret-id cert_private_key --region us-east-1 | jq .SecretString | tr -d '"')

	echo -e "$private_key_file_contents" > "$private_key_file"
	echo -e "$cert_file_contents" > "$cert_file"

	sed -i "s|/etc/pki/tls/private/localhost.key|$private_key_file|g" /etc/httpd/conf.d/ssl.conf
	sed -i "s|/etc/pki/tls/certs/localhost.crt|$cert_file|g" /etc/httpd/conf.d/ssl.conf
}

harden_apache() {
	echo "\
	ServerSignature Off
	ServerTokens Prod

	<Directory />
		Options -Indexes
		Order allow,deny
		Allow from all
	</Directory>" >> /etc/httpd/conf.d/hardening.conf
}

# Redirect to user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

log INFO "Running: $enable_php7"
$enable_php7

log INFO "Running: $clean_metadata"
$clean_metadata

#log INFO "$yum_update"
$yum_update

log INFO "Running: $install_dependencies"
$install_dependencies

log INFO "Running: $get_wordpress"
$get_wordpress

log INFO "Running: $decompress_wordpress"
$decompress_wordpress

log INFO "Running: $copy_sample"
$copy_sample

log INFO "Running: $copy_html_files"
$copy_html_files

log INFO "Running: $chown_www"
$chown_www

log INFO "health check creation"
create_health_check_file

log INFO "Fixing wordpress config"
fix_wordpress_config

log INFO "Creating crontabs for system security updates"
create_crontabs

log INFO "Adding hardening.conf for apache"
harden_apache

log INFO "Adding ssl.conf for apache"
create_ssl_config

log INFO "Running: $httpd_start"
$httpd_start

log INFO "Finished $0"
