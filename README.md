# SidekiqCustomSerializer

## Installation

Add this line to your application's Gemfile:

    gem 'sidekiq_custom_serializer', git: 'git://github.com/elado/sidekiq_custom_serializer.git'


And then execute:

    $ bundle

Story behind this repo:

https://github.com/mperham/sidekiq/pull/357

This gem is a patch for Sidekiq. It overrides the way Sidekiq saves references to objects in Redis, and the way it retrieves them back.

If you use #delay method on an ActiveRecord instance, the custom serializer will serialize the instance into a string, and know how to deserialize it back when the task runs.

For example:

```
spiderman.delay.send_follow_notification_from(batman)
```

will save under redis `SIDEKIQ@User@1` and `SIDEKIQ@User@2` along with the method name. Then, when the task runs, it'll fetch the user objects by ID from the DB.

Instead of creating worker classes for each background job and grow your app code, this gem will easily let you use current methods without changing the parameters they get to use IDs nor storing huge YAML dumps in Redis.
