class UserMailer < ActionMailer::Base
  def greetings(email, name)
    mail from: "test@domain.com", to: email, subject: "Hello #{name}"
  end
end
