module Sidekiq
  module Extensions
    class DelayedModel
      def perform(*msg)
        (target, method_name, args) = ArgsSerializer.deserialize_message(*msg)
        target.send(method_name, *args)
      end
    end

    module ActiveRecord
      module ClassMethods
        def sidekiq_deserialize(string)
          where(id: string.to_i).first
        end
      end
      
      module InstanceMethods
        def sidekiq_serialize
          "SIDEKIQ@#{self.class.name}@#{self.id}"
        end
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end

  end
end
