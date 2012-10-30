require 'spec_helper'

describe "Class Methods" do
  it "allows delayed execution of ActiveRecord class methods" do
    Sidekiq::Client.registered_queues.should == []
    Sidekiq.redis {|c| c.llen('queue:default') }.should == 0

    User.delay.long_class_method("with_argument")

    Sidekiq::Client.registered_queues.should == ['default']
    Sidekiq.redis {|c| c.llen('queue:default') }.should == 1

    perform_last_job!(Sidekiq::Extensions::DelayedModel).should == "done long_class_method with_argument"
  end

  it "allows delayed scheduling of AR class methods" do
    Sidekiq.redis {|c| c.zcard('schedule') }.should == 0

    User.delay_for(5.days).long_class_method

    Sidekiq.redis {|c| c.zcard('schedule') }.should == 1
  end

  class SomeClass
    def self.doit(arg)
      ["done", arg]
    end
  end

  it 'allows delay of any ole class method' do
    today = Date.today
    SomeClass.delay.doit(Date.today)

    perform_last_job!(Sidekiq::Extensions::DelayedClass).should == ["done", today]
  end
end