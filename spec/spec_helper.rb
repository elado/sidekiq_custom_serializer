require 'sidekiq'
require 'sidekiq_custom_serializer'
require 'active_record'
require 'action_mailer'
require 'sidekiq/rails'

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:all) do
    Sidekiq.hook_rails!
    ActionMailer::Base.perform_deliveries = false
  end

  config.before(:each) do
    dir = File.join(File.dirname(__FILE__), 'support/db')

    old_db = File.join(dir, 'test.sqlite3')
    blank_db = File.join(dir, '.blank.sqlite3')
    
    if !File.exists?(blank_db)
      FileUtils.cp(File.join(dir, 'test.sqlite3'), File.join(dir, '.blank.sqlite3'))
    elsif File.exists?(old_db)
      FileUtils.rm(old_db)
      FileUtils.cp(File.join(dir, '.blank.sqlite3'), File.join(dir, 'test.sqlite3'))
    end
  end
  
  config.before(:each) do
    Sidekiq.redis {|conn| conn.flushdb }
  end
end

require 'support/connection'
require 'support/models'
require 'support/mailers'

REDIS = Sidekiq::RedisConnection.create(:url => "redis://localhost/15", :namespace => 'sidekiq_custom_serializer_test')
Sidekiq.redis = REDIS

def perform_last_job!(performer)
  msg = JSON.parse(Sidekiq.redis {|c| c.lrange "queue:default", 0, -1 }[0])
  performer.new.perform(*msg['args'])
end