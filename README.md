# Vagrant + Openscholar

This simple Vagrant configuration will load up a Ubuntu virtual box and will begin installing OpenScholar and all the dependencies needed to build it it.

## Steps

1. Run the vagrantfile from the command line with "Vagrant up".
2. On your personal system, add "192.168.44.46	openscholar.lh"  to your hostfile (alter the IP as necessary).
3. When the script is finished, go to http://openscholar.lh/install.php to start the install process and make sure to select the "OpenScholar" profile.
4. When asked about the database, enter "openscholar" for the database name, "drupaluser" for the database user, and "MyPassw0rd" for the password. You can change these as necessary in the provisioning script "provisioning/installs.sh".
* NOTE: If, for whatever reason, you need to connect directly as root, the root mysql password is "MyRootPassw0rd".

## Notes

1. The install script has not been thoroughly tested. If it should fail, you can destroy the box using "Vagrant destroy" and restart. Otherwise, you can connect to the machine with "Vagrant ssh" and run the provisioning script "provisioning/installs.sh" manually.
2. The install script is designed to help set up a rapid development environment only. It should not be used in a production environment.

## About OpenScholar

OpenScholar is a Drupal solution designed to provide a quick and easy way to create and maintain academic websites. You can find out more information here:

* http://theopenscholar.org/
* https://www.drupal.org/project/openscholar
* https://github.com/openscholar/openscholar
