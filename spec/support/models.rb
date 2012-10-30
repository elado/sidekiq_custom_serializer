class User < ActiveRecord::Base
  def self.long_class_method(arg)
    "done long_class_method #{arg}"
  end

  def long_instance_method(arg)
    "done long_instance_method #{arg}"
  end
end
