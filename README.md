# Deploying React App
A script for deploying react using apache on port 80
# How to use
````
git clone https://github.com/ATKatary/deploy-react.git
sudo bash deploy-react/deploy.sh
````
# Script breakdown
_**Note: Steps 1 - 3 are only done the first time you deploy**_ </b>
1. We configure our server to allow outgoing traffic and deny incoming traffic
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

2. We allow incoming traffic over ssh (port 22) and ports 80/443
```
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

3. We install apache2 and setup a virtualhost for port 80 that servers our build </br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- The configuration is inside /etc/apache2/sites-enabled/frontend.conf
```
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
```

4. We create a production build for the react app
```
cd $appDir
npm run build
```

5. We move our build to /var/www so apache2 can access it
```
sudo mkdir /var/www/frontend
sudo mv $appDir/build/* /var/www/frontend/
```

6. We create .htaccess file inside of our build at /var/www/frontend </br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- This file is what allows you to have multiple pages and route between them
```
links=/var/www/frontend/.htaccess
sudo touch $links
echo "Options -MultiViews" > $links
echo "RewriteEngine On" >> $links
echo -e "RewriteCond %{REQUEST_FILENAME} !-f" >> $links
echo -e "RewriteRule ^ index.html [QSA,L]" >> $links
```

7. We enable the site and reload apache2
```
echo "Enabling site ..."
sudo a2ensite frontend.conf

sudo systemctl restart apache2.service
```
