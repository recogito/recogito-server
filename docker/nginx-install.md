Assumes Amazon Linux 2023

### Install Nginx

Update 
~~~
sudo dnf update 
sudo dnf install -y nginx
sudo systemctl start nginx.service 
sudo systemctl status nginx.service 
sudo systemctl enable nginx.service 
~~~

### Install Pip

~~~
sudo yum install pip
~~~

### Install Certbot

~~~
sudo /opt/certbot/bin/pip install certbot certbot-nginx
~~~

~~~
sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot
~~~

### Setup server configs

See [nginx.conf file](./nginx.conf)

Update the `/etc/nginx/nginx.conf` file with one in repo

### Studio password with htpasswd

Setting the Studio password

~~~
sudo yum install htpasswd
~~~

Set the Studio password

~~~
sudo htpasswd -c /etc/apache2/.htpasswd supabase
~~~

It will prompt for password.

### Restart Nginx

~~~
sudo systemctl restart nginx.service
~~~

### Get Certs

~~~
sudo certbot --nginx
~~~

