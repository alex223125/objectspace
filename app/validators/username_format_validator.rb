class UsernameFormatValidator < ActiveModel::Validator

  # Conditions for username:
  # do not allow spaces
  # allow capital English letters
  # allow lowercased English letters
  # allow digits
  # the string may not contain both a hyphen and an underscore
  #
  # hyphen: hyphen cannot be at the beginning or at the end of the string;
  # There can be any amount of hyphens but consecutively there can be only 1 hyphen (a--b is invalid).
  #
  # underscores: underscore cannot be at the beginning or at the end of the string;
  # There can be any amount of underscores but consecutively there can be only 1 underscore (a__b is invalid)
  #
  # the string must contain at least 1 character (letter)


  USERNAME_CONDITIONS = /
      \A           # match start of string
      (?!.*        # begin negative lookahead and match >= 0 characters
        (?:--|__)  # match -- or __ in a non-capture group
      )            # end negative lookahead
      (?![-_])     # do not match - or _ at the beginning of the string
      (?!.*[-_]\z) # do not match - or _ at the end of the string
      (?!          # begin negative lookahead
        .*-.*_     # match - followed by _
        |          # or
        .*_.*-     # match _ followed by -
      )            # end negative lookahead
      (?=.*[a-z])  # match at least one letter
      [a-z\d_-]+   # match one or more English letters, digits, _ or -
      \z           # match end of string
      /ix          # case indifference and free-spacing modes

  def validate(record)
    binding.pry
    if record.username.match?(USERNAME_CONDITIONS)
      # do nothing
    else
      record.errors.add(:username, I18n.t('errors.messages.username_invalid'))
    end
  end

end