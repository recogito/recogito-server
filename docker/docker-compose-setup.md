# Running Recogito Server in Docker Compose Mode

Recogito Server is based on the [Supabase Platform](https://supabase.com/). The following instructions detail how to self-host the Recogito Server using [Docker Compose](https://docs.docker.com/compose/).

## Prerequisites

* A server with an internet accessible address.
* Software:
  * [Git](https://git-scm.com/)
  * [Docker](https://www.docker.com/)
  * On some Linux instances [Docker Compose](https://docs.docker.com/compose/install/standalone/)
* (Recommended) A NFS mount to store important data

### For Storage

Either:
* Access to a AWS S3 Bucket
* A file system that supports [xattr - Extended Attributes](https://man7.org/linux/man-pages/man7/xattr.7.html)

## Run Docker 

Start the docker service.

On AWS Linux 2023:

~~~shell
sudo systemctl start docker
~~~

##  Clone the Recogito Server

In your home directory run:

~~~shell
git clone https://github.com/recogito/recogito-bonn.git
~~~

## Setup the Volumes Directory

Copy the volumes directory form the recogito-bonn reporitory. It is recommended that this volume directory be on an NFS mount.  In the examples below the NFS mount is at `./nfs`

~~~shell
sudo cp -R ./recogito-bonn/docker/volumes ./nfs/
~~~

Remove the `.hold` directory from the db/data directory.

~~~shell
sudo rm ./nfs/volumes/db/data/.hold
~~~

If you are using AWS and S3 for storage, setup a `.aws` directory in the mount or local directory and add a credentials file

~~~shell
sudo mkdir ./nfs/.aws

sudo nano ./nfs/.aws/credentials
~~~

And add the following lines and save:

~~~shell
[default]
aws_access_key_id = <your access key>
aws_secret_access_key = <your secret access key>
~~~

## NGINX and serving a domain

If you are hosting Recoigito-Bonn on a domain, please see the [NGinX Install Guide](./nginx-install.md)

## Copy the docker-compose.yml file

~~~shell
cp ./recogito-bonn/docker/docker-compose.yml .
~~~

## Setup the .env File

Copy the `.env.example` file

~~~
cp ./recogito-bonn/docker/.env.example ./.env
~~~

For POSTGRES_PASSWORD generate a appropriately secure password

For JWT_SECRET you can generate a key in this way:

~~~shell
openssl rand -base64 64 | tr -d '\n'
~~~

For the ANON_KEY and SERVICE_ROLE key use the [Supabase Utility](https://supabase.com/docs/guides/self-hosting#api-keys)

If you are not using SAML2 then set SAML_ENABLED to false

If you are using SAML2 then set SAML_ENABLED true and provide a SAML_SIGNING_KEY.  You can generate a SAML key as follows:

~~~shell
openssl genrsa -out Rsa_private.key 1024
~~~

You can then copy the results between `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----` into this [tool](https://capitalizemytitle.com/tools/remove-line-breaks/) (*be sure to check Remove all whitespace)

Use this value for SAML_SIGNING_KEY.

Fill in infor for your SMTP server to enable emails to users.

If you are using the file system for Document storage change the STORAGE_BACKEND to `file`.

If you are using S3 for storage, enter the appropiate values for `AWS_REGION` and `GLOBAL_S3_BUCKET`.

Set all of the volumes data using whatever you used in the this [step](#setup-the-volumes-directory)

## Update kong.yml

~~~shell
sudo nano ./nfs/volumes/api.kong.yml
~~~

Replace the values at the top of the file with your Service key and Anon key

~~~yaml
    - username: anon
    keyauth_credentials:
      - key: <your service key>
    - username: service_role
    keyauth_credentials:
      - key: <your anon key>

~~~

## Try running docker-compose

Do a test run at this point of starting docker-compose

~~~shell
docker-compose up -d
~~~

The first time this is run, the images will be downloaded.

## Access Supabase Studio

At this point you should be able to point your browser at http://<the_IP_address>:3000 and access the Supabase Studio web app.

## Create the documents storage bucket

Navigate in Studio to Storage and create a `New Bucket` called documents (do *not* make it public).

## Migrate the DB

The new DB needs to be migrated to the Recogito schema. From the command line at the root of the recogito-bonn project run:

~~~shell
supabase db push --db-url postgresql://postgres:<password>@<ip_address>:5432/postgres
~~~

## Seed the policies

The policies for each table need to be seeded in the DB.

Navigate to the SQL Editor view in Studio and paste the script seed_policies.sql into the SQL Query window and execute.  The result should be `Success. No rows returned`

## Create The Admin, Default Groups and Roles

Using the program `create-default-groups.js` create the default groups, roles, and initial org admin user. This program should be run from your local dev setup at the root of the `recogito-bonn` repo.

~~~shell
ORG_ADMIN_PW=<your admin password> SUPABASE_SERVICE_KEY=<your service key> SUPABASE_HOST=<your host>:8000 node create-default-groups.js -f ./recogito-bonn-config.json -g 350abe76-937b-4a9b-9600-9b1f856db250
~~~

# Localhost vs. Domain Hosting

What you do next is based on whether you are doing a local deployment for testing and development, or hosting Recogito Bonn on a domain.

[Localhost Deployment](#localhost-deployment)



## Localhost Deployment

For a localhost deployment the final step is to build the client.

### Clone the Recogito-Client Repository

~~~shell
git clone https://github.com/recogito/recogito-client.git
~~~

### Update the .env file

Swith to the recogito-client directory

~~~shell
cd recogito-client
~~~

Copy the example .env file

~~~
cp ./.env.example .env
~~~

The value necessary for building and deploying the container are as follows

~~~dotenv
###
# Public vars are available on server and client
###

# Supabase
PUBLIC_SUPABASE=localhost:8000
PUBLIC_SUPABASE_API_KEY=<anon key>

# Usersnap feedback form
PUBLIC_USERSNAP_GLOBAL_API_KEY=6e60701c-60b3-4480-9f78-fdd893cf0132
PUBLIC_USERSNAP_PROJECT_API_KEY=160965e0-8bdc-4525-9fb9-e079107afa8b

# SSO domain
PUBLIC_SSO_DOMAIN="example.com"

###
# Non-public vars stay on the server
###

# Secret 'salt' to compute the realtime room identifiers
ROOM_SECRET=<a text string secret>

# IIIF server location
IIIF_URL="http://www.example.com/iiif/public/resources"
IIIF_KEY="your-iiif-server-api-key"
IIIF_PROJECT_ID="iiif-project-uuid-for-this-app"
~~~

Build the client. Specify a tag to make it unique to your environment.

~~~
sudo docker build -t client-test-1 .
~~~

replace the image version in the main docker-compose.yml file with the image you just created:

~~~dotenv
cd ~
nano docker-compose.yml
~~~

~~~yaml
  client:
    image: client-test-1:latest
    container_name: bonn-client
~~~

## Try logging into The Recogito Client

You should now be able to login to the recogito client using the admin email (admin@performantsoftware.com) and the password you set in the `ORG_ADMIN_PW` variable above.

http://<your host>:8090













