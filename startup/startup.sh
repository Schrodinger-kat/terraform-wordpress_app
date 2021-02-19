#!/bin/bash
sudo apt-get update
sudo apt install apache2 -y
sudo apt-get install git -y
git clone https://github.com/Schrodinger-kat/google-cloud-activity.git
cd google-cloud-activity/wordpress/
sudo cp 000-default.conf /etc/apache2/sites-enabled/
sudo service apache2 restart
cd /var/www/
sudo mv html public_html
sudo apt-get install php7.0 php-pear php7.0-mysql
sudo service apache2 restart
cd /var/www/public_html
#for debugging purpose
sudo cat > index.php << EOF
    <?php echo phpinfo();?>
EOF
sudo mkdir jishnn
cd jishnn
sudo wget https://wordpress.org/latest.zip
sudo apt-get install unzip -y
unzip latest.zip

sudo chown -R www-data /var/www/public_html
sudo chmod -R 755 /var/www/public_html
