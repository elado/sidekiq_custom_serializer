require 'spec_helper'

class SomeClass
  def self.long_method(user, time, number, string)
    [user, time, number, string]
  end
end

describe "ActiveRecord" do
  it "allows delayed execution of ActiveRecord instance methods" do
    Sidekiq::Client.registered_queues.should == []
    Sidekiq.redis {|c| c.llen('queue:default') }.should == 0

    user = User.create!
    user.delay.long_instance_method("with_argument")

    Sidekiq::Client.registered_queues.should == ['default']
    Sidekiq.redis {|c| c.llen('queue:default') }.should == 1

    perform_last_job!(Sidekiq::Extensions::DelayedModel).should == "done long_instance_method with_argument"
  end

  it "allows setting queue from options" do
    Sidekiq::Client.registered_queues.should == []
    Sidekiq.redis {|c| c.llen('queue:custom_queue') }.should == 0

    user = User.create!
    user.delay(queue: :custom_queue).long_instance_method("with_argument")
    
    Sidekiq::Client.registered_queues.should == ['custom_queue']
    Sidekiq.redis {|c| c.llen('queue:custom_queue') }.should == 1
  end

  it "sends an recieves an instance of ActiveRecord as a parameter" do
    user = User.create!
    time = Time.now
    number = 3.14
    string = "hello"
    SomeClass.delay.long_method(user, time, number, string)

    perform_last_job!(Sidekiq::Extensions::DelayedModel).should == [user, time, number, string]
  end
end