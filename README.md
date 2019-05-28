# Noticent

Noticent is a Ruby gem for user notification management. It is written to deliver a developer friendly way to managing application notifications in a typical web application. Many applications have user notification: sending emails when a task is done or support for webhooks or Slack upon certain events. Noticent makes it easy to write maintainable code for notification subscription and delivery in a typical web application.


The primary design goal for Noticent is developer friendliness. Using Noticent, you should be able to:

- Create new notification types
- Tell the current state of notifications, subscriptions and distribution channels.
- Support multiple notification channels like email, chat applications, mobile push, webhooks and more.
- Test your notifications

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'noticent'
```

And then execute:

```bash
    bundle
```

Or install it yourself as:

```bash
    gem install noticent
```

### Run Generators

```bash
rails g noticent:install
```

Now run the migrations

```bash
rake db:migrate
```

## Usage

Noticent is written to be used in a Rails application but you should be able to use it in other Ruby / Rack based applications if you need to.

### Basics

Noticent uses the following concepts:

#### Alert

Alert is a type of notification. For example, a new user signing up could be defined as an Alert.

#### Scope

Scope is like a namespace for Alerts. In many applications, you will only have 1 Scope. However, sometimes you might have different types of Alerts for different parts of your application. For example, "new blog post written" and "blog post updated" Alerts could be associated with the a "blog" Scope, while a "new comment added" Alert is associated with another Scope. Using Scope is useful when you have many different groups of Alerts in your application.

#### Channel

Channel is a distribution channel for your Alerts. Examples of Channels are Email, Slack, Webhook, Mobile or browser notification.

#### Recipient

Recipient is a person or system that receives Alerts. This could be a user for Channels like Email or a system for a Webhook Channel.

#### Payload

Payload is a data structure (class) that carries everything you'd need to send an Alert to a Recipient over a Channel.

### Integration

Noticent tries to make very few assumptions about your application, like what you call your Recipients or what your Scopes are. However it also enforces some opinions to make the whole system easier to use and maintain.

### Configuration

The most important part of using Noticent is the configuration part where you define scopes, channels and your alerts. Once configured, you can hook it up to the rest of your code. This example assumes integration in a Rails application.

If you have run the generators, you should now have a file called `config/initializers/noticent.rb`. You can edit it as you like: 

```ruby
Noticent.configure do
    channel :email

    scope :account do
        alert :new_signup do
            notify :owner
        end
        alert :new_team_member do
            notify :users
        end
    end
end
```

Now you'd need to tell Noticent how to send emails by creating an email channel. This can be done in `app/models/noticent/channels/email.rb`:

```ruby
class Email < ::Noticent::Channel
    def new_signup
        # send email here
    end

    def new_team_member
        # send email here
    end
end
```

Now that we have our channel, we can define a Payload. We can do this in `app/modesl/noticent/account_payload.rb`:

```ruby
class AccountPayload
    attr_reader :account
    attr_reader :current_user

    def initializer(account_id, current_user)
        @account = Account.find account_id
    end

    def users
        @account.users
    end

    def owner
        @account.owner
    end
end
```

You can now create your email templates in `app/models/noticent/views/email` with 2 files called `new_signup.html.erb` and `new_team_member.html.erb` the same way you would write email templates for Rails mailers:

```html
Hello <%= @owner.name %>!
A new user just signed up.
```

and

```html
You now have a new team member. Make sure to say hi!
```

Until now, this is very much like Rail's own mailers and follows the same principles: Payload is like a model, Channel is the equivalent of a controller and the html view file is the view.

This first difference here is that you can use "front matter" in your views. This is useful when you need more than just text or HTML in your notifications. For an email channel, the front matter can hold a template for the email subject for example:

```html
subject: New member for <%= @team.name %>
---
Hello!

You now have a new team member who signed up as an admin for <%= @team.name %>
```

In the channel, you can use this:

```ruby
class EmailChannel < ::Noticent::Channel

def new_member
    data, content = render
    send_email(subject: data[:subject], content: content) # this is an example code
end
```

The `render` method looks for the right file under the `views` directory and loads and renders the ERB file while returning any front matter if available.

Use of front matter becomes more important in channels that have a more complex API like Slack (message color can be stored in the front matter) for example.

Now let's go back to our configuration file and see what else we can do. Here is an example of a Noticent configuration file in full:

```ruby
Noticent.configure do
    hooks :pre_channel_registration, my_hooks
    hooks :post_alert_registration, my_hooks

    channel :email
    channel :slack
    channel :webhook, klass: MyWebhookChannel
    channel :dashboard, group: :internal

    scope :account do
        alert :new_user do
            notify :users
            notify(:staff).on(:internal)
            notify :owners
        end
    end

    scope :comment do
        alert :new_comment do
            notify :commenter
            notify :auther
        end
        alert :comment_updated do
            notify :commenter
        end
    end

    scope :staff_comment, payload_class: AnotherPayloadClass do
        alert :marked_as_answer do
            notify(:staff).on(:internal)
        end
    end
end
```

### Sending Alerts

To send an Alert, call the `notify` method:

```ruby
account_payload = AccountPayload.new(1, user.first)
Noticent.notify(:new_user, account_payload)
```

### Using Each Noticent Component

#### Payload

To understand how to use Noticent, it's important to know the conventions it uses. First, payloads: A payload is a class and should have methods named after each one of the recipient groups specified in the configuration. For example, if an alert should be sent to `users` then payload should have a method or attribute called `users`. This method is called at the point the notifications need to be sent to retrieve the recipients. It is up to you what each recipient is: it could be an email address (string) or the entire user object or an ID. Your channel class will be given this and should know how to handle it.

It is recommended to explicitly define the class type of each scope. This ensures integrity of the alerts in runtime:

```ruby
Noticent.configure do
    scope :account, payload_class: SomeOtherClass do
        #...
    end
end
```

If specified, the type of the payload is checked against this class at runtime (when `Notify` is called).

#### Channel

Channels should be derived from `::Noticent::Channel` class and called the same as with the name of the channel with a `Channel` suffix: `email` would be `EmailChannel` and `slack` will be `SlackChannel`. Also, channels should have a method for each type of alert they are supposed to handle. Channel class can be changed using the `klass` argument during definition.

Channels can also have groups. If no group is supplied, a channel will belong to the `default` group. Groups can be used to send alerts to a subset of channels:

```ruby
Noticent.configure do
    channel :email
    channel :private_emails, group: :internal
    channel :slack, group: :internal

    alert :some_event do
        notify :users
        notify(:staff).on(:internal)
    end
end
```

You can use `render` in the channel code to render and return the view file and its front matter (if available). By default, channel will look for `html` and `erb` as the file content and format. You can change these both when calling `render` or at the top of the controller:

```ruby
class SlackChannel < ::Noticent:Channel
    default_format :json
    default_ext :erb
end
```

or

```ruby
data, content = render(format: :erb, ext: :json)
```

You can also use a different layout for each render:

```ruby
data, content = render layout: 'my_layout'
```

By default, no layout is used.

#### Views

Views are like Rails views. Noticent supports rendering ERB files. You can also use layouts just like Rails. A layout is like a shared template `layout.html.erb`:

```html
This is at the top

<%= yield %>

This is at the bottom
```

`some_event.html.erb`:

```html
foo: bar
buzz: fuzz
---
This will be in the middle
```

Views can be of any type, like HTML or JSON which can be useful with API based channels.

## Opt-ins

Noticent uses a combination of channel, alert and scope to determine if a recipient has subscribed to receive an alert or not. By default it uses the `ActiveRecordOptInProvider` class which uses a single database table for the process. You can write your own Opt-in provider if you want to store subscription (opt-in) state in a different place. See `ActiveRecordOptInProvider` for what such provider requires to operate.

Use `Noticent.configuration.opt_in_provider`'s `opt_in`, `opt_out` and `opted_in?` methods to change the opt-in state of each recipient.

## Migration

Noticent provides a method to add new alerts or remove deprecated alerts from the existing recipients.

TO BE WRITTEN.

## Validation

Every time Noticent starts, it runs some validations on the configuration, classes that are defined, channels and alerts to make sure they are defined correctly and the supporting classes are in compliance with the requirements.

## Testing Your Alerts

TO BE WRITTEN

## Hooks

Hooks are extension points for Noticent. You can register them in your configuration:

```ruby
Noticent.configure do
    hooks.add(:pre_channel_registration, custom_hook)
end
```

The valid hook points are `pre_channel_registration`, `post_channel_registration`, `pre_alert_registration` and `post_alert_registration`. Once the hook point is reached, the given object is called on the same method name as with the hook name.

## Customization

The following items can be customized:

`base_dir`: Base directory for all Noticent assets.

`base_module_name`: Base module name for all Noticent assets.

`opt_in_provider`: Opt-in provider class. Default is `ActiveRecordOptInProvider`.

`logger`: Logger class. Default is `stdout`

`halt_on_error`: Should notification fail after the first incident of an error during rendering. Default is `false`


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/khash/noticent.
