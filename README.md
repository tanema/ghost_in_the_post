# GhostInThePost #

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

### Configuration ###

GhostInThePost can be configured in an initializer

```ruby
#config/initializers/ghost_in_the_post.rb
GhostInThePost.config = {
  phantomjs_path: "/usr/local/bin/phantomjs", #[required] path of phantomjs, if this is not set there will be an error
  includes: ["application.js"],               #global include of a javascript file, this will be injected into every email
  remove_js_tags: true,                       #remove script tags after javascript has been processed
  timeout: 1000,                              #timeout after js has been inserted to make sure it is run
  wait_event: 'ghost_in_the_post:done'        #an event that can be fire on the document to trigger finish of the processing early
}
```

You can also include a javascript file for individual mail methods

```ruby
class NewsletterMailer < ActionMailer::Base
  include GhostInThePost::Automatic

  def user_newsletter(user)
    #include extra emails for this email
    include_script "email.js", "util.js"
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
