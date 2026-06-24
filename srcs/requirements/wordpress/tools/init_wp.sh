#!/bin/sh

set -e

# Load password
export DB_USER_PASSWORD=$(cat /run/secrets/db_user_password)
export WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
export WP_ROOT_PASSWORD=$(cat /run/secrets/wp_root_password)

# Creat the directory required by PHP-FPM for runtime files and socket
mkdir -p /run/php

# Configure PHP-FPM to listen on TCP port 9000 instead of a Unix socket (because of the Docker organization)
sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf
echo "> php/fpm listens on port:9000 now"

# Wait until the MariaDB service becomes available
echo "> waiting for mariadb. . ."
until mysqladmin ping -h "mariadb" -u "$DB_USER" --password="$DB_USER_PASSWORD" --silent; do
	sleep 1
done

# Install WordPress only if no configuration already exists( prevent WordPress from being reinstalled on container restart)
if [ ! -f "/var/www/html/wp-config.php" ]; then
	echo "> making a fresh WP installation"

	# Create the web root and ensure it is empty
	#mkdir -p /var/www/ #SDU
	mkdir -p /var/www/html
	cd /var/www/html
	rm -rf *

	# Download the latest WordPress files
	wp core download --allow-root

	# Generate wp-config.php
	wp config create \
		--dbname="${DB_DATABASE}"\
		--dbhost="mariadb:3306"\
		--dbuser="${DB_USER}"\
		--dbpass="${DB_USER_PASSWORD}"\
		--allow-root

	# the main wp install
	wp config set WP_HOME "https://${WP_DOMAIN}" --allow-root
	wp config set WP_SITEURL "https://${WP_DOMAIN}" --allow-root

	# Create the WordPress site and administrator account
	wp core install \
		--url="https://${WP_DOMAIN}" \
		--title=${WP_NAME} \
		--admin_user=${WP_ROOT} \
		--admin_password=${WP_ROOT_PASSWORD} \
		--admin_email=${WP_ROOT_MAIL} \
		--allow-root

	# Create an additional non-admin user
	wp user create \
		"${WP_USER}" \
		"${WP_USER_MAIL}" \
		--user_pass="${WP_USER_PASSWORD}" \
		--allow-root

	# Enable Redis object cache plugin #Bonus (stores frequently used results in memory)
	wp redis enable --allow-root

	# Set ownership and permissions for WordPress files
	chown -R www-data:www-data /var/www/html/
	chown -R www-data:www-data /var/www/html/wp-content
	chmod -R 755 /var/www/html/wp-content
fi

# Start PHP-FPM in foreground mode so the container remains running
echo "> letting php handler run"
exec /usr/sbin/php-fpm7.4 -F
