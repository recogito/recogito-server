## Useful Commands

All assumed to be executed at ~/

### Remove all data from volumes

~~~
sudo rm -rf ./efs/volumes
~~~

### Copy repo volumes

~~~
sudo cp -R ./recogito-bonn/docker/volumes ./efs/
~~~

### Remove the .hold file

~~~
sudo rm ./efs/volumes/db/data/.hold
~~~

### Build the client

~~~
docker build ./recogito-client/ -t lwjameson/recogito-client:latest
~~~

### Push the client

~~~
docker push lwjameson/recogito-client:<tag>
~~~

### Tail NGINX error logs

~~~
sudo tail -f /var/log/nginx/error.log
~~~

### Tail NginX access logs

~~~
sudo tail -f /var/log/nginx/access.log
~~~

### Restart NginX

~~~
sudo systemctl restart nginx.service
~~~

### Edit the docker compose file

~~~
sudo rm docker-compose.yml && nano docker-compose.yml
~~~

### Start the docker compose file

~~~
docker-compose up .
~~~


### Clear stuff from DB

~~~sql
DELETE FROM group_users;
DELETE FROM organization_groups;
DELETE FROM project_groups;
DELETE FROM default_groups;
DELETE FROM roles;
DELETE FROM role_policies; 
~~~
