class User < ApplicationRecord
  include Ownerable


  USERNAME_MAXIMUM_LENGTH = 40.freeze

  searchkick callbacks: :async,
             text_middle: [:name, :username]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         # :validatable,
         # devise-security gem
         :secure_validatable,
         # for Google OmniAuth
        :omniauthable, omniauth_providers: [:google_oauth2]

  has_one :dashboard
  # has_many :articles, class_name: "Articles::Article"
  # has_many :folders
  has_many :repositories
  has_many :folders, through: :repositories
  has_many :comments

  has_one_attached :avatar
  has_one_attached :cropped_avatar

  validates :name, presence: true, allow_blank: false
  validates :email, presence: true, allow_blank: false

  #username
  validates :username, presence:true, allow_blank: false, length: { maximum: USERNAME_MAXIMUM_LENGTH }
  validates :username, :email, uniqueness: true
  validates_with UsernameFormatValidator

  validates_acceptance_of :tos_agreement, allow_nil: false, on: :create, :message => "Terms and privacy policy must be accepted."

  attr_reader :cropped_image_result

  def tos_agreement_signed?
    self.tos_agreement == true
  end

  # def root_folder
  #   self.folders.where(responsibility_type: Folders::ResponsibilityTypeTypes[:user_root]).first
  # end

  def self.from_omniauth(auth)
    binding.pry
    user = Users::User.where(provider: auth.provider, uid: auth.uid).first
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
