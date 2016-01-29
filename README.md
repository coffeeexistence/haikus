###Joining the project
If you would like to join this project, send a message through the "Get Your First Rails Job" meetup (http://www.meetup.com/laruby/events/227867151/), including your email and github username, and we'll invite you to the github repo, the pivotal project, and our Hipchat channel.

###Pull Requests, Merging, and PivotalTracker
"Start" a ticket on PivotalTracker (https://www.pivotaltracker.com/n/projects/1516637) and add yourself as an owner

Use the ticket id# to name branches in the following format:
+ feature/ticket_number-INITIALS
+ bugfix/ticket_number-INITIALS

Push branch.

Open a pull request. In the pull request:

title: branch name
description: link to the Pivotal Tracker ticket, terse description of what the ticket covers

Click "Finish" ticket on PivotalTracker

Once PR is approved, merge PR and "Deliver" ticket on PivotalTracker

Product Manager will Accept or Reject the ticket

--

###To install:

Make sure you have the correct Ruby version. You'll find it both in .ruby-version, at the root of the project, and in the Gemfile.

```sh
bundle install
bundle exec rake db:create
bundle exec rake db:migrate
rails s
```

###Test Coverage
Every time you run tests locally, you will also regenerate Simplecov coverage docs. Make sure you commit these last, after your PR has already been approved.

To view test coverage docs, visit <hostname>/coverage/index.html

###Production URL
http://ec2-52-34-168-78.us-west-2.compute.amazonaws.com

####AWS Deployment Dev Access
If you are an authorized dev for this project and want to do production deployment on the AWS instance, do the following through your console/terminal:

1. Generate ssh key pair `ssh-keygen if username`  note: swap username with something of your choice, I usually use my local account name, if unsure do `whoami` and use the name returned to generate your ssh key pair.
2.  2 files are created, a public key file and a private key file (**username.pub** and **username** respectively). note on macs the private key file has no file extension but on some operating systems it may be **username.pem**
3. Add the private key to your keychain: `ssh-add username`
4. Send your username.pub to the AWS admin (Richard, find him on Hipchat) and he will add you.
5. After you are added. from a console/terminal at the root of the Haikus project, run `cap production deploy`
6. You can also now ssh into AWS via `ssh haikus@ec2-52-34-168-78.us-west-2.compute.amazonaws.com`

####AWS Instance Setup Guide
This setup guide will walk you through on how to setup an instance of AWS using passenger + nginx. At the end of this guide you should have a welcome screen at your AWS instance URL.

#####Local Host
1. Sign up for AWS if you havent. Create a new EC2 instance, choose Ubuntu. micro if you want it to stay free.
2. Add HTTP port 80 into the security group.
3. Create key pair.
4. Select the newly created key pair.
5. Deploy the instance
6. Add the private key to your keychain `ssh-add location_of_file/file_name.pem`, note you may have to change the pem file permission first `chmod 400 file_name.pem`
7. Login via `ssh ubuntu@your_aws_public_DNS_or_IP`

#####AWS
1. Do the following commands in order, this makes the following step in installing nginx much smoother (note you dont have to create the swapfile if your AWS instance is not a micro, micro has 1GB ram and no swapfile space by default): 
```sh
sudo apt-get install libcurl4-openssl-dev
sudo dd if=/dev/zero of=/swap bs=1M count=1024
sudo mkswap /swap
sudo swapon /swap
```
2. Create a new user **haikus** `sudo adduser haikus`
3. add new user to sudoer group `sudo adduser haikus sudo`
4. login as haikus `su haikus`
5. Follow Steps 1~7: https://www.digitalocean.com/community/tutorials/how-to-install-rails-and-nginx-with-passenger-on-ubuntu
6. For step 7 to work do this: http://askubuntu.com/questions/257108/trying-to-start-nginx-on-vps-i-get-nginx-unrecognized-service
7. Start nginx via `sudo service nginx start`

#####Local Host
1. Verify that nginx has indeed started by going to your AWS Instance URL from your favorite web browser. You should see the Welcome to nginx! page.

####AWS Adding Dev Access
Before we continue on, this section focuses on administration of how to add user dev access to the AWS instance. A prerequisite is to do steps 1~4 of **AWS Deployment Dev Access**
#####Local Host
1. `scp username.pub ubuntu@ec2-52-34-168-78.us-west-2.compute.amazonaws.com`

#####AWS
1. Login to AWS as **haikus** (you may need to login as ubuntu first and then switch user to haikus)
2. We want to make a .ssh folder if it doesn't already exist and put the public key sent over into **authorized_key**
   ```sh
   cd ~haikus
   mkdir .ssh
   cat /tmp/username.pub >> .ssh/authorized_keys
   ```

#####Local Host
1. Setup is now complete. You can try `ssh haikus@ec2-52-34-168-78.us-west-2.compute.amazonaws.com`

####AWS Capistrano Setup
This guide will setup Capistrano to allow a full production deployment to the AWS instance.
Local Host

#####Local Host
1. At the start of this project Charlie had already added in the required Capistrano gems into the gemfile, take a look to see the dependencies.
2. At project root do command `cap install`. This will generate a few files that we will need.
3. Modify Capfile like below, note that order does matter!
	```sh
	# Load DSL and set up stages
	require 'capistrano/setup'

	# Include default deployment tasks
	require 'capistrano/deploy'

	require 'capistrano/bundler'
	require 'capistrano/rails/assets'
	require 'capistrano/rails/migrations'
	require 'capistrano/rvm'
	```
4. Modify deploy.rb add the following below `lock '3.4.0'`
	```sh
	set :rvm_ruby_version, '2.3.0@haikus'
	set :application, 'haikus'
	set :repo_url, 'git@github.com:charliemcelfresh/haikus.git'
	## set :branch, "branch_name"
	```
	Note the last line is commented out. So if you ever want to test a production deployment with a particular branch, uncomment that and put in the branch name that you are deploying, and make sure you save, commit and push to the branch on github.

	Now, also note at the end of the file there is a chunk of code that starts off with **namespace...**. Replace all that with the following:
	```sh
	namespace :deploy do
	  desc 'Restart application'
	  task :restart do
	    on roles(:web), in: :sequence, wait: 5 do
	      execute :mkdir, '-p', "#{ release_path }/tmp"
	      execute :touch, release_path.join('tmp/restart.txt')
	    end
	  end
	end

	after 'deploy:publishing', 'deploy:restart'
	```
	Production server keys off of that to restart the application so it's very important that it exists.

5.	Within **deploy.rb** we have a gemset called **2.3.0@haikus**. Now we need to set that up:
	```sh
	rvm gemset create haikus
	rvm gemset use haikus
	gem install bundle
	bundle install
	```
6. Update **config/deploy/production.rb**, add the following line at the top: 
	```sh
	server 'ec2-52-34-168-78.us-west-2.compute.amazonaws.com', user: 'haikus', roles: %w{app db web}
	```
7. Within **config/environments/production.rb**, find the following and comment it out so it looks like the following: `# config.assets.js_compressor = :uglifier`
So with this particular project we dont have any js and once we deploy, with precompiling the system wants to use uglifier but we dont have that gem in the gemfile. Since we are not using it, just comment it out.
8. Within **config/initializers/database.yml**, add the following to production:
	```sh
	username: <%= ENV["PG_USERNAME"] %>
	password: <%= ENV["PG_PASSWORD"] %>
  	```

#####AWS
1. Login as **haikus**. Remember the rvm gemset? We are going to need that here. I'm going to just quickly describe what you'll have to do, but basically on your local host you need to export that gemset. Take the export file and load it onto AWS (scp or whatever else). And then you use rvm to import it in. I'll let you google to victory here but make sure that rvm is using the same version of Ruby and using the same gemset.
2. Install Postgres: 
```sh
sudo apt-get install postgresql
sudo apt-get install libpq-dev
```
3. Create Postgres user according to **database.yml**: 
```sh
$ sudo -u postgres psql
create user paid_programmer with password 'password';
alter role paid_programmer superuser createrole createdb replication;
create database haikus_production owner paid_programmer;
create user haikus with password 'password';
alter role haikus superuser createrole createdb replication;
```
	Note: the last time I did this I didn't have to create a role for the deployment account but this time I had to. Had errors where Capistrano wanted to use haikus to do stuff so I created haikus role and everything worked out after that.
4. Update pg_hba.conf file. `sudo nano /etc/postgresql/9.3/main/pg_hba.conf`
   Find the following and set methods to **trust**
   ```sh
	  # TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD

	# "local" is for Unix domain socket connections only
	local   all         all                               trust
	# IPv4 local connections:
	host    all         all         127.0.0.1/32          trust
	# IPv6 local connections:
	host    all         all         ::1/128               trust
	``` 
5. Install git: `sudo apt-get install git`
6. Setup github access, add another key to your account: https://help.github.com/articles/generating-ssh-keys/
7. Update nginx configuration: `sudo nano /opt/nginx/conf/nginx.conf`
```sh
server {

        listen       80;

        server_name  put_your_aws_instance_public_DNS_here;

        passenger_enabled on;

        rails_env production;

        root /var/www/your_app_name_here/current/public;
        .....
```
Comment out all html paths within the server block. Make sure you do this because they have a higher presedence than your application's routes!!!
7. Create `/var/www/` via `sudo mkdir` and then do `sudo chown -R haikus /var/www`  When you deploy later the application will live here.

#####Local Host
1.  Create a new **secret_key_base**, use cmd `rake secret` and then copy the output key

#####Remote Host
1. Edit `~/.profile` go to the end of the file and add in 
	```sh
	export SECRET_KEY_BASE = paste_the_secret_key_generated_from_local_host_here
	export PG_USERNAME=paid_programmer
	export PG_PASSWORD=password
	```
2. `source ~/.profile` and use `echo $ENV_VAR_NAME` and make sure those 3 variables above exist.
3. Restart nginx `sudo service nginx restart`

#####Local Host
1. We are basically ready to deploy. If you are deploying master, make sure all the local changes you made are merged into master. If you are testing, make sure that within **deploy.rb** you have the set branch flag turned on and have the proper branch name set, and the branch exist on github.
2. Deploy the production code: `cap production deploy` The console should not error out.
3. Verify through your favorite browser that the app is up and running.
