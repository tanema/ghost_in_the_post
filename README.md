# GhostInThePost #

[![Build history](https://secure.travis-ci.org/tanema/ghost_in_the_post.png)](http://travis-ci.org/#!/tanema/ghost_in_the_post)
[![coverage status](https://coveralls.io/repos/github/tanema/ghost_in_the_post/badge.svg?branch=master)](https://coveralls.io/github/tanema/ghost_in_the_post?branch=master)
[![Code Climate](https://codeclimate.com/github/tanema/ghost_in_the_post/badges/gpa.svg)](https://codeclimate.com/github/tanema/ghost_in_the_post)
[![Gem Version](https://badge.fury.io/rb/ghost_in_the_post.svg)](https://badge.fury.io/rb/ghost_in_the_post)
[![Dependency Status](https://gemnasium.com/tanema/ghost_in_the_post.svg)](https://gemnasium.com/tanema/ghost_in_the_post)

> Using Phantomjs to pre-run javascript in emails

GhostInThePost uses [Phantomjs](http://phantomjs.org/) to run javascript in the html of your emails so that you can render mustache templates and run scripts that will change the DOM before sending. GhostInThePost will also remove script tags after everything is run so it wont be included in the final email.

## Installation ##

Add this gem to your Gemfile and run `bundle install`.

```ruby
gem 'ghost_in_the_post'
```

## Usage ##

`ghost_in_the_post` have two primary means of usage. The first on is the "Automatic usage", which does almost everything automatically when you deliver the email. "Manual usage" means you will have to specifically call ghost on the email. For the most part you should only need automatic.


### Automatic usage ###

Include the `GhostInThePost::Automatic` module inside your mailer. GhostInThePost will do its magic when you try to deliver the message:

```ruby
class NewsletterMailer < ActionMailer::Base
  include GhostInThePost::Automatic

  def user_newsletter(user)
    mail to: user.email, subject: subject_for_user(user)
  end

end

# email has the original body; GhostInThePost has not been invoked yet
email = NewsletterMailer.user_newsletter(User.first)
# This triggers GhostInThePost to process the javascript before it sends
email.deliver
```

If you dont need GhostInThePost for every email you can call it on only the emails you need.

### Manual usage ###

Include the `GhostInThePost::Mailer` module inside your `ActionMailer` and call `ghost` on the emails that you need. The `ghost` email returns the processed email so you can call it on the mail method as follows

```ruby
class NewsletterMailer < ActionMailer::Base
  include GhostInThePost::Mailer

  #call ghost of this email
  def user_newsletter(user)
    mail(to: user.email, subject: subject_for_user(user)).ghost
  end

  #notifications dont require js
  def user_notification(user)
    mail(to: user.email, subject: subject_for_user(user))
  end

end
```

### Usage Notes ###

#### Templating Warning ####

The html is processed with nokogiri and as such is validated html. However, this means that it will url-encode attributes. For instance `<img src="{{source}}"/>` will be transformed into `<img src=\"%7B%7Bsource%7D%7D\">`
It is recomended that you precompile your js templates (using hogan-assets or something similar and include it as js) so that you are not depending on text that is url-encoded.

#### JSON from the DOM ####
If you are parsing JSON from a data attribute, you need to decode the string first:

Instead of this:

```javascript
var el = document.getElementById('myDiv');
var data = JSON.parse(el.dataset.json);
```

do this:

```javascript
var el = document.getElementById('myDiv');
var data = JSON.parse(decodeURIComponent(el.dataset.json));
```

This will make your code work both in the email and in a web browser

### Configuration ###

GhostInThePost can be configured in an initializer

```ruby
#config/initializers/ghost_in_the_post.rb
GhostInThePost.config = {
  phantomjs_path: "/usr/local/bin/phantomjs", #[required] path of phantomjs, if this is not set there will be an error
  includes: ["application.js"],               #global include of a javascript file, this will be injected into every email
  remove_js_tags: true,                       #remove script tags after javascript has been processed
  raise_js_errors: true,                      #Raise a GhostInThePost::GhostJSError if there is an error in the js included in the email
  raise_asset_errors: true,                   #Raise an GhostInThePost::AssetNotFoundError if an script provided for running cannot be found
  timeout: 1000,                              #timeout after js has been inserted to make sure it is run
  wait_event: 'ghost_in_the_post:done',       #an event that can be fire on the document to trigger finish of the processing early
  debug: false,                               #will give a link to the temp file of html for review if there was an error
}
```

You can also change the includes, timeout and wait event per method like the following

```ruby
class NewsletterMailer < ActionMailer::Base
  include GhostInThePost::Automatic

  def user_newsletter(user)
    #include extra emails for this email
    include_script "email.js", "util.js"
    set_ghost_timeout 43
    set_ghost_wait_event "done"
    mail to: user.email, subject: subject_for_user(user)
  end

end
```

### Inspiration

This gem took a lot of design queues from [roadie-rails](https://github.com/Mange/roadie-rails) and works along side of it so you can preprocess css and pre-run js all at once!

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the test suite and check the output (`rake`)
4. Add tests for your feature or fix (please)
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request
