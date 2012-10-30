module Sidekiq
  module Extensions
    class ArgsSerializer
      SIDEKIQ_CUSTOM_SERIALIZATION_FORMAT = /\ASIDEKIQ@(.+)/

      def self.serialize(obj)
        serialize_value(obj).to_yaml
      end
      
      def self.deserialize(str)
        deserialize_value(YAML.load(str))
      end

      def self.serialize_message(target, method_name, *args)
        [ serialize(target), method_name, serialize(args) ]
      end

      def self.deserialize_message(*msg)
        [ deserialize(msg[0]), msg[1], deserialize(msg[2]) ]
      end

      private
      def self.serialize_value(obj)
        if obj.respond_to?(:sidekiq_serialize)
          obj.sidekiq_serialize
        else
          case obj
          when Array then obj.map { |o| serialize_value(o) }
          when Hash  then obj.inject({}) { |memo, (k, v)| memo[k] = serialize_value(v); memo }
          else            obj
          end
        end
      end

      def self.deserialize_value(obj)
        case obj
        when SIDEKIQ_CUSTOM_SERIALIZATION_FORMAT
          klass_name, args = $1.split('@')
          klass = klass_name.constantize
          klass.respond_to?(:sidekiq_deserialize) && args ? klass.sidekiq_deserialize(args) : klass
        when Array then obj.map { |item| deserialize_value(item) }
        when Hash  then obj.inject({}) { |memo, (k, v)| memo[k] = deserialize_value(v); memo }
        else            obj
        end
      end
    end
  end
end
