module Sidekiq
  module Extensions
    class Proxy < BasicObject
      def method_missing(name, *args)
        serialized_args = ArgsSerializer.serialize_message(@target, name, *args)

        @performable.client_push({ 'class' => @performable, 'args' => serialized_args }.merge(@opts))
      end
    end

  end
end
