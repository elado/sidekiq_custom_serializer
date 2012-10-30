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


This Gem supplies ActiveRecord, classes and modules serialization and deserialization out of the box. For other things, you can define two methods (below is the implementation for ActiveRecord):

1. Instance method for serialization:

```
def sidekiq_serialize
  "SIDEKIQ@#{self.class.name}@#{self.id}"
end
```

2. Class method for deserialization:

```
def self.sidekiq_deserialize(string)
  where(id: string.to_i).first
end
```

Every argument in Redis with `SIDEKIQ@` prefix will be inspected. The string after the first `@` is the class name, and then the ID or any other parameter, that will be passed to the `sidekiq_deserialize(string)` method.


