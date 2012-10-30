require 'spec_helper'

describe Sidekiq::Extensions::ArgsSerializer do
  def ser(o)
    Sidekiq::Extensions::ArgsSerializer.serialize(o)
  end

  def deser(s)
    Sidekiq::Extensions::ArgsSerializer.deserialize(s)
  end

  it 'serializes a hash' do
    hash = { sym: "value", "string" => "value 2", class: User }
    hash.should == deser(ser(hash))
  end

  it 'serializes active record class' do
    ser(User).should =~ /SIDEKIQ@User/
    deser(ser(User)).should == User
  end

  it 'serializes active record instance' do
    user = User.create!
    ser(user).should =~ /SIDEKIQ@User@#{user.id}/
    deser(ser(user)).should == user
  end

  class SomeClass
  end

  module SomeModule
  end

  it 'serializes class' do
    ser(SomeClass).should =~ /SIDEKIQ@SomeClass/
    deser(ser(SomeClass)).should == SomeClass
  end

  it 'serializes module' do
    ser(SomeModule).should =~ /SIDEKIQ@SomeModule/
    deser(ser(SomeModule)).should == SomeModule
  end

  it 'serializes array' do
    deser(ser([1, 2, 3])).should == [1, 2, 3]
  end

  it 'serializes complex object' do
    user = User.create!
    user_2 = User.create!
    user_3 = User.create!
    obj = [user, [user_2], { user_3: user_3, number: 1, string: "s" }]
    deser(ser(obj)).should == obj
  end

  it 'serializes date' do
    today = Date.today
    deser(ser(today)).should == today
  end
end
