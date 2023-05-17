class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         # :validatable,
         # devise-security gem
         :secure_validatable,
         # for Google OmniAuth
        :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :folders

  # validates :name, :username, :email, :presence => true
  validates :name, presence: true, allow_blank: false
  validates :username, presence: true, allow_blank: false
  validates :email, presence: true, allow_blank: false

  validates :username, :email, uniqueness: true
  validates_acceptance_of :tos_agreement, allow_nil: false, on: :create, :message => "Terms and privacy policy must be accepted."

  def tos_agreement_signed?
    self.tos_agreement == true
  end

  def root_folder
    self.folders.where(responsibility_type: Folders::ResponsibilityTypeTypes[:user_root]).first
  end


  def self.from_omniauth(auth)
    binding.pry
    user = User.where(provider: auth.provider, uid: auth.uid).first
    if user.present?
      user
      # do nothing
    else
      user = Users::User.where(provider: auth.provider, uid: auth.uid).new do |user|
        user.username = "user#{auth.uid}"
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
        user.name = auth.info.name # assuming the user model has a name
        # user.avatar_url = auth.info.image # assuming the user model has an image
        # If you are using confirmable and the provider(s) you use validate emails,
        # uncomment the line below to skip the confirmation emails.
        # user.skip_confirmation!
      end
      user.save(validate: false)
      user
    end
  end


end
