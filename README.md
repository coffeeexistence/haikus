###Joining the project
If you would like to join this project, send a message through the "Get Your First Rails Job" meetup (http://www.meetup.com/laruby/events/227867151/), including your email and github username, and we'll invite you to the github repo, the pivotal project, and our Hipchat channel.

###Pull Requests, Merging, and PivotalTracker
"Start" a ticket on PivotalTracker (https://www.pivotaltracker.com/n/projects/1516637) and add yourself as an owner

Use the ticket id# to name branches in the following format:
+ feature/ticket_number-INITIALS
+ bugfix/ticket_number-INITIALS

Push branch, open pull request, and "Finish" ticket on PivotalTracker

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

#####AWS Instance
1. Do the following commands in order, this makes the following step in installing nginx much smoother (note you dont have to create the swapfile if your AWS instance is not a micro, micro has 1GB ram and no swapfile space by default): 
```sh
sudo apt-get install libcurl4-openssl-dev
sudo dd if=/dev/zero of=/swap bs=1M count=1024
sudo mkswap /swap
sudo swapon /swap
```
2. Follow Steps 1~7: https://www.digitalocean.com/community/tutorials/how-to-install-rails-and-nginx-with-passenger-on-ubuntu
3. For step 7 to work do this: http://askubuntu.com/questions/257108/trying-to-start-nginx-on-vps-i-get-nginx-unrecognized-service
4. Start nginx via `sudo service nginx start`

#####Local Host
1. Verify that nginx has indeed started by going to your AWS Instance URL from your favorite web browser. You should see the Welcome to nginx! page.
