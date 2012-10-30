require 'spec_helper'

describe "Action Mailer" do
  it "allows delayed delivery of ActionMailer mails" do
    Sidekiq::Client.registered_queues.should == []
    Sidekiq.redis {|c| c.llen('queue:default') }.should == 0

    UserMailer.delay.greetings("user@domain.com", "John Doe")

    Sidekiq::Client.registered_queues.should == ['default']
    Sidekiq.redis {|c| c.llen('queue:default') }.should == 1

    mail_message = perform_last_job!(Sidekiq::Extensions::DelayedMailer)

    mail_message.to.should == ["user@domain.com"]
    mail_message.subject.should == "Hello John Doe"
  end

  it "allows delayed scheduling of AM mails" do
    Sidekiq.redis {|c| c.zcard('schedule') }.should == 0

    UserMailer.delay_for(5.days).greetings(1, 2)

    Sidekiq.redis {|c| c.zcard('schedule') }.should == 1
  end
end