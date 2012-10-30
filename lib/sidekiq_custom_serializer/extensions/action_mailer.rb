require 'sidekiq/extensions/generic_proxy'

module Sidekiq
  module Extensions
    class DelayedMailer
      def perform(*msg)
        (target, method_name, args) = ArgsSerializer.deserialize_message(*msg)
        target.send(method_name, *args).deliver
      end
    end
  end
end
