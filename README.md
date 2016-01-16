###Pull Requests, Merging, and PivotalTracker
"Start" a ticket on PivotalTracker and add yourself as an owner

Use the ticket id# to name branches in the following format:
+ feature/ticket_number-INITIALS
+ bugfix/ticket_number-INITIALS

Push branch, open pull request, and "Finish" ticket on PivotalTracker

Once PR is approved, merge PR and "Deliver" ticket on PivotalTracker

Product Manager will Accept or Reject the ticket

--

###To install:

```sh
bundle install
rails s
```

###Verify install:
```sh
curl http://localhost:3000/ping
```

###Making requests
Any endpoint other than /ping requires a valid token. Make a token in a console like this:
```
> ApiKey.create!
```

See http://apidock.com/rails/ActionController/HttpAuthentication/Token/ControllerMethods/authenticate_or_request_with_http_token for an example of how to set a token in your Authorization header.

###API Docs
Anytime you make a change to the API, you must regenerate rspec_api_documentation docs:
bundle exec rake docs:generate

Make sure you commit your changes, as these are static files. Always put these changes in a separate commit, after you have completed any PR. We don't want to make everyone look at these files every time you have a PR that touches API code.

To view the API docs, visit <hostname>/docs

###Test Coverage
Every time you run tests locally, you will also regenerate Simplecov coverage docs. Make sure you commit these last, after your PR has already been approved.

To view test coverage docs, visit <hostname>/coverage/index.html


