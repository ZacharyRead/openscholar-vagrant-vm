#If running these commands manually (e.g. if this script fails), switch to root/superuser (sudo su).

#Set the mysql-server password to avoid the prompt later.
debconf-set-selections <<< 'mysql-server mysql-server/root_password password MyRootPassw0rd'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password MyRootPassw0rd'

#Install the necessary packages to run Drupal, if they don't already exist.
aptitude update
aptitude -y install apache2-mpm-worker \
                      mysql-server \
                      php5 \
                      php5-mysql \
                      php5-xsl \
                      git \
                      make \
                      php5-gd \
                      php5-curl \
                      libssh2-php \
                      unzip \
                      php5-dev \
                      libapache2-mod-php5 \
                      nodejs \
                      npm

#Install Bower, needed by OpenScholar's build script.
npm install bower -g

#Allow Bower to run via root user; otherwise OpenScholar's build script will fail.
echo '{ "allow_root": true }' > /root/.bowerrc

#Symlink nodejs to node to prevent issue later. See: https://github.com/nodejs/node-v0.x-archive/issues/3911
ln -s /usr/bin/nodejs /usr/bin/node

cd /var/www/
mkdir os
cd /var/www/os/

#Install and extract latest OpenScholar package
wget https://github.com/openscholar/openscholar/archive/SCHOLAR-3.65.6.tar.gz
tar -zxvf SCHOLAR-3.65.6.tar.gz openscholar-SCHOLAR-3.65.6/ --strip 1
rm SCHOLAR-3.65.6.tar.gz


cd /home/

#Install Composer and make it globally available
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

#Install Drush 7 via Composer
composer global require drush/drush:7.*

#Add composer to the .bashrc file to be able to use Drush from command line
echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

cd /var/www/os/
./scripts/build

#Alter our default php.ini to set these settings off
sed -e '/^[^;]*expose_php/s/=.*$/= Off/' -i.bak /etc/php5/apache2/php.ini
sed -e '/^[^;]*allow_url_fopen/s/=.*$/= Off/' -i.bak /etc/php5/apache2/php.ini

#Alter our default php.ini and my.cnf files per https://github.com/openscholar/openscholar/wiki/Troubleshooting
#Note: We do not need to change the Timeout value, as the default value (300) should be higher than what they specify.
sed -e '/^[^;]*memory_limit/s/=.*$/= 256M/' -i.bak /etc/php5/apache2/php.ini
sed -e '/^[^;]*max_execution_time/s/=.*$/= Off/' -i.bak /etc/php5/apache2/php.ini
sed -e '/^[^;]*max_allowed_packet/s/=.*$/= 50M/' -i.bak /etc/mysql/my.cnf
#NOTE FOR PRODUCTION: After the installation, return the above to the default values because DOS attack may freeze your server.

#Enable rewrite functionality and htaccess files in Apache
a2enmod rewrite

#Restart Apache
service apache2 restart

#Symlink /var/www/os/www to /var/www/html/openscholar so that Apache recognizes it
ln -s /var/www/os/www /var/www/html/openscholar

#Create the file with VirtualHost configuration in /etc/apache2/sites-enabled/
sh -c "echo '<VirtualHost *:80>
        DocumentRoot /var/www/html/openscholar/
        ServerName openscholar.lh
        <Directory /var/www/html/openscholar/>
                Options +Indexes +FollowSymLinks +MultiViews +Includes
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>
</VirtualHost>' > /etc/apache2/sites-enabled/openscholar.conf"

#Add the host to the hosts file. This will allow us to access http://openscholar.lh
sh -c "echo 127.0.0.1 openscholar.lh >> /etc/hosts"

#Create the missing Drupal file directory and set its ownership to the Apache user
mkdir /var/www/html/openscholar/sites/default/files
chmod 755 /var/www/html/openscholar/sites/default/files
chown www-data:www-data /var/www/html/openscholar/sites/default/files -R

#Copy default.settings.php to settings.php and set its ownership to the Apache user
cp /var/www/html/openscholar/sites/default/default.settings.php /var/www/html/openscholar/sites/default/settings.php
chown www-data:www-data /var/www/html/openscholar/sites/default/settings.php

#Create our mysql user, password and database
mysql --user="root" --password="MyRootPassw0rd" --execute="CREATE DATABASE openscholar;"
mysql --user="root" --password="MyRootPassw0rd" --execute="CREATE USER drupaluser@localhost IDENTIFIED BY 'MyPassw0rd';"
mysql --user="root" --password="MyRootPassw0rd" --execute="GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER,CREATE TEMPORARY TABLES,LOCK TABLES ON openscholar.* TO drupaluser@localhost;"
mysql --user="root" --password="MyRootPassw0rd" --execute="FLUSH PRIVILEGES;"


#Make sure to add "192.168.44.46	openscholar.lh" to your hostfile (alter IP as necessary)
#Go to http://openscholar.lh/install.php to start the install process and select the "OpenScholar" profile.
#For the database:
#   database name:     openscholar
#   database user:     drupaluser
#   database password: MyPassw0rd
#The mysql root password is MyRootPassw0rd
