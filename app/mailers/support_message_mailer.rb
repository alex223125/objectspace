# app/mailers/support_message_mailer.rb

class SupportMessageMailer < ApplicationMailer
  def email_confirmation(support_message)
    @support_message = support_message

    @confirmation_url =
      confirm_support_message_url(
        token: support_message.email_confirmation_token
      )

    mail(
      to: support_message.email,
      subject: "Please confirm your message to our project"
    )
  end
end