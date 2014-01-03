# MultipleMan

[![Code Climate](https://codeclimate.com/github/influitive/multiple_man.png)](https://codeclimate.com/github/influitive/multiple_man)

[![CircleCI](https://circleci.com/gh/influitive/multiple_man)](https://circleci.com/gh/influitive/multiple_man.png)]

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

      # Where you want to log errors to. Should be an instance of Logger
      # Defaults to the Rails logger (for Rails) or STDOUT otherwise.
      config.logger = Logger.new(STDOUT)
    end

### Publishing models

To publish a model, include the following in your model definition:

    class Widget < ActiveRecord::Base
      include MultipleMan::Publisher
      publish fields: [:id, :name, :type], identifier: :code
    end

You can use the following options when publishing:

- `fields` - An array of all the fields you want to send to the message queue. These
  can be either ActiveRecord attributes or methods on your model.
- `identifier` - Either a symbol or a proc used by MultipleMan to identify your model.
  `id` is used by default and is generally fine, unless you're working in a multi-tenant
  environment where ids may be shared between two different models of the same class.

### Subscribing to models

You can subscribe to a model as follows (in a seperate consumer app):

    class Widget < ActiveRecord::Base
      include MultipleMan::Subscriber
    end

Currently, there's a few assumptions made of subscriber models:

- They need to have all of the fields that are published.
- They need an additional field, called `multiple_man_identifier`, that is the
  same type as what's passed from the publisher side (just an integer if you're using
  id)

Once you've set up your subscribers, you'll need to run a background worker to manage
the subscription process. Just run the following:

    rake multiple_man:worker

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
