# # frozen_string_literal: true
#
# require 'uri'
#
# class EmailValidator < ActiveModel::Validator
#   def validate(record)
#     return if record.email.match? URI::MailTo::EMAIL_REGEXP
#
#     record.errors[:email] << I18n.t('errors.messages.invalid')
#     record.errors[:email] << 'has an invalid format'
#   end
# end

class EmailValidator < ActiveModel::Validator
  def validate(record)
    binding.pry
    if ValidEmail2::Address.new(record.email).valid?
      # if EmailAddress.valid?(record.email)
      return
    else
      binding.pry
      record.errors.add(:email, I18n.t('errors.messages.email_invalid'))
      # raise ActiveRecord::Rollback
    end
  end
end