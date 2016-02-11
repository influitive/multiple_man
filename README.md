# MultipleMan

[![Code Climate](https://codeclimate.com/github/influitive/multiple_man.png)](https://codeclimate.com/github/influitive/multiple_man)

[![CircleCI](https://circleci.com/gh/influitive/multiple_man.png)](https://circleci.com/gh/influitive/multiple_man)

MultipleMan synchronizes your ActiveRecord models between Rails
apps, using RabbitMQ to send messages between your applications.
It's heavily inspired by Promiscuous, but differs in a few ways:

- MultipleMan makes a hard assumption that you're using
  ActiveRecord for your models. This simplifies how models
  are sychronized, which offers a few benefits like:
- Transactions are fully supported in MultipleMan. Records
  which aren't committed fully to the database won't be sent
  to your message queue.

## Installation

Add this line to your application's Gemfile:

    gem 'multiple_man'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install multiple_man

## Usage

### Configuration

MultipleMan can be configured (ideally inside an initializer) by
calling MultipleMan.configure like so:

    MultipleMan.configure do |config|
      # A connection string to your local server. Defaults to localhost.
      config.connection = "amqp://example.com"

      # The topic name to push to. If you have multiple
      # multiple man apps, this should be unique per application. Publishers
      # and subscribers should always use the same topic.
      config.topic_name = "multiple_man"

      # The application name (used for subscribers) - defaults to your
      # Rails application name if you're using rails
      config.app_name = "MyApp"

      # Specify what should happen when MultipleMan
      # encounters an exception.
      config.on_error do |exception|
        ErrorLogger.log(exception)
      end

      # Where you want to log errors to. Should be an instance of Logger
      # Defaults to the Rails logger (for Rails) or STDOUT otherwise.
      config.logger = Logger.new(STDOUT)
    end

### A note on errors

It's extremely important to specify the `on_error` setting
in your configuration. ActiveRecord by default swallows
exceptions encountered in an `after_commit` block, meaning
that without handling these errors through the configuration,
they will be silently ignored.

### Publishing models

#### Directly from the model

Include this in your model definition:

    class Widget < ActiveRecord::Base
      include MultipleMan::Publisher
      publish fields: [:id, :name, :type]
    end

#### In an initializer / config file

Add this to an initializer (i.e. `multiple_man.rb`):

```
MultipleMan.publish Widget, fields: [:id, :name, :type]
```

You can use the following options when publishing:

- `fields` - An array of all the fields you want to send to the message queue. These
  can be either ActiveRecord attributes or methods on your model.
- `with` - As an alternative to `fields`, you can specify
  an ActiveRecord serializer (or anything that takes your
  record in the constructor and has an `as_json` method) to
  serialize models instead.
- `as` - If you want the name of the model from the
  perspective of MultipleMan to be different than the model
  name in Rails, specify `as` with the name you want to use.
  Useful for STI.
- `identify_by` - Specify an array of fields that MultipleMan
  should use to identify your record on the subscriber end.
  `id` is used by default and is generally fine, unless you're working in a multi-tenant environment where ids may
  be shared between two different models of the same class.
- (DEPRECATED) `identifier` - Either a symbol or a proc used by MultipleMan to identify your model.

### Publishing

By default, MultipleMan will publish all of your models whenever you save a model (in an `after_commit` hook). If you need to manually publish models, you can do so with the `multiple_man_publish` method, which acts like a scope on your models, like so:

```
# Publish all widgets to MultipleMan
Widget.multiple_man_publish  

# Publish a subset of widgets to MultipleMan
Widget.where(published: true).multiple_man_publish

# Publish an individual widget
Widget.first.multiple_man_publish
```

If you're publishing multiple models, it's best to use the
version of multiple_man_publish that operates on a collection. By calling the individual version, a channel is opened and closed for each model, which can impact the thoroughput of MultipleMan.

### Subscribing to models

You can subscribe to a model as follows (in a seperate consumer app):

    class Widget < ActiveRecord::Base
      include MultipleMan::Subscriber
      subscribe fields: [:id, :name]
    end

You can pass the following options to the `subscribe` call:

- `fields` - Specify which fields you want to receive from
  the publisher. If this is blank, then any field that is published where your subscriber model has a corresponding `field=` method will be subscribed to.
- `to` - If the model name on the publishing end differs from your model name, specify
  the name of the model from the publisher's perspective.
- `identify_by` - If you want to identify this model by a different set of fields than
  what the publisher specifies, you can specify it here. For instance, you may have an 
  `id` numeric field on the publisher, but the publisher also supplies a `uuid` field. You
  can specify `identify_by: :uuid` to override which field is used. Accepts either a single
  field or an array of fields.
  
You can also remap fields within the subscriber, like so:

    class Widget < ActiveRecord::Base
      include MultipleMan::Subscriber
      subscribe fields: {
        id: :id,
        name: :remote_name
      }
    end
    
The keys in the supplied hash indicate the field name on the payload (i.e. the publisher
side) and the values represent which local field you want to map them to.


By default, MultipleMan will attempt to identify which model on the subscriber matches a model sent by the publisher by id. However, if your publisher specifies an `identify_by` array, MultipleMan will locate your record by finding a record where all of those fields match.

### DEPRECATED: multiple_man_identifier

If your publisher specifies an `identifier` option, you *must* include a column on the subscriber side called `multiple_man_identifier`. MultipleMan will attempt to locate models on the subscriber side by this column.

## Listening for model changes

If you want to do something other than populate a model on MultipleMan messages,
you can listen for messages and process them however you'd like:

```
def ListenerClass
  include MultipleMan::Listener
  listen_to 'ModelName'

  def create(payload)
    # do something when a model is created
  end
end
```

## Listening for subscriptions

Once you've set up your subscribers, you'll need to run a background worker to manage
the subscription process. Just run the following:

    rake multiple_man:worker

## Seeding

One common problem when using MultipleMan on an existing project is that there's already a lot of data that you want to process using your listeners. MultipleMan provides a mechanism called "seeding" to accomplish this.

1. On the subscriber side, start listening for seed requests with the following rake task:

```
rake multiple_man:seed
```

2. On the publisher side, indicate that your models should be seeded with the following command:

```
MyModel.multiple_man_publish(:seed)
```

3. Stop the seeder rake task when all of your messages have been processed. You can check your RabbitMQ server

## Versioning

Because you may have different versions of MultipleMan between publishers and subscribers,
MultipleMan attaches **versions** to every message sent. This ensures that updates to payloads,
metadata, etc. will not affect processing of your messages.

In general, a subscriber will not be able to process messages published by a newer version of
MultipleMan. We use **minor versions** to indicate changes that may contain a breaking change 
to payload formats.

As a consequence, when upgrading MultipleMan, it's always safe to upgrade patch versions, but
when upgrading to a new major or minor version, ensure that you upgrade your subscribers
prior to upgrading your publishers (if two services both subscribe and publish, you'll need to 
update them synchronously.) 

Currently, the following versions support the following payload versions:

- **Payload v1** - 1.0.x
- **Payload v2** - 1.1.x

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The MIT License (MIT)

Copyright (c) 2014 Influitive Corporation

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/influitive/multiple_man/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
