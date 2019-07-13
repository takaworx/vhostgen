if [ "$(whoami)" != 'root' ]; then
echo "You have to execute this script as root user"
exit 1;
fi
read -p "Enter the server name your want (user.website.com): " servn
servn=${servn:-user.website.com}
read -p "Enter the path of directory you wanna use. NOTE: Don't forget the trailing slash (/var/www/html/): " dir
dir=${dir:-/var/www/html/}
read -p "Enter document root ($dir$servn): " docroot
docroot=${docroot:-$dir$servn}
read -p "Enter the user you wanna use (root): " usr
usr=${usr:-root}
read -p "Enter the listened IP for the server (*): " listen
listen=${listen:-*}

if ! mkdir -p $dir$servn; then
echo "Web directory already Exist !"
else
echo "Web directory created with success !"
fi

echo "<?php echo '<h1>$servn</h1>'; ?>" > $dir$servn/index.php
chown -R $usr:$usr $dir$servn
chmod -R '755' $dir$servn
mkdir /var/log/$servn

alias=www.$servn

echo "#### $servn
<VirtualHost $listen:80>
ServerName $servn
ServerAlias $alias
DocumentRoot $docroot
<Directory $docroot>
Options Indexes FollowSymLinks MultiViews
AllowOverride All
Order allow,deny
Allow from all
Require all granted
</Directory>
</VirtualHost>" > /etc/apache2/sites-available/$servn.conf
if ! echo -e /etc/apache2/sites-available/$servn.conf; then
echo "Virtual host wasn't created !"
else
echo "Virtual host created !"
fi

a2ensite $servn.conf

service apache2 restart

echo "======================================"
echo "All works done! You should be able to see your website at http://$servn"
echo "======================================"