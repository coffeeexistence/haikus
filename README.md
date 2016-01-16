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


