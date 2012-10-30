module Sidekiq
  module Extensions
    class DelayedClass
      def perform(*msg)
        (target, method_name, args) = ArgsSerializer.deserialize_message(*msg)
        target.send(method_name, *args)
      end
    end

    module Klass
      def sidekiq_serialize
        "SIDEKIQ@#{self.name}"
      end
    end

  end
end

Class.send(:include, Sidekiq::Extensions::Klass)
Module.send(:include, Sidekiq::Extensions::Klass)
