echo "What is the path of the react app?" && read appDir

cd $appDir
npm run build
cd $appDir/build

if [ ! -f /etc/apache2/sites-available/frontend.conf ]
then
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 80
    sudo ufw allow 443
    sudo ufw enable

    sudo apt update
    sudo apt install apache2 -y
    sudo ufw allow 'Apache'

    echo "Setting up apache server ..."
    cd /etc/apache2/sites-available
    sudo touch frontend.conf
    sudo echo "<VirtualHost *:80>" >  frontend.conf
    echo "What is the name of your server (ex: www.example.com]?:" && read serverName

    sudo echo -e "\tServerName ${serverName}" >> frontend.conf
    sudo echo -e "\tServerAdmin user@localhost" >> frontend.conf
    sudo echo -e "\tDocumentRoot /var/www/frontend\n" >> frontend.conf

    sudo echo -e "\t<Directory /var/www/frontend/>" >> frontend.conf
    sudo echo -e "\t\tOptions Indexes FollowSymLinks" >> frontend.conf
    sudo echo -e "\t\tAllowOverride All" >> frontend.conf
    sudo echo -e "\t\tRequire all granted" >> frontend.conf
    sudo echo -e "\t</Directory>\n" >> frontend.conf

    sudo echo -e '\tErrorLog ${APACHE_LOG_DIR}/error.log' >> frontend.conf
    sudo echo -e '\tCustomLog ${APACHE_LOG_DIR}/access.log combined\n' >> frontend.conf
    sudo echo -e "</VirtualHost>" >> frontend.conf

    echo "Enabling site ..."
    sudo a2ensite frontend.conf
    sudo a2dissite 000-default.conf
    sudo a2enmod rewrite
else
    echo "Site already deployed on apache"
fi

cd $appDir
if [ -d  /var/www/frontend ]
then
    echo "App has been deployed before, overwriting ..."
    sudo rm -rf /var/www/frontend
else
    echo "First time deploying app ..."
fi

sudo mkdir /var/www/frontend
sudo cp -r $appDir/build/* /var/www/frontend/
rm -rf $appDir/build

links=/var/www/frontend/.htaccess
sudo touch $links
echo "Options -MultiViews" > $links
echo "RewriteEngine On" >> $links
echo -e "RewriteCond %{REQUEST_FILENAME} !-f" >> $links
echo -e "RewriteRule ^ index.html [QSA,L]" >> $links

echo "Enabling site ..."
sudo a2ensite frontend.conf

sudo systemctl restart apache2.service
echo -e '\033[0;32mDeployment successful!\033[0m'