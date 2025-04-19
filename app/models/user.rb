class User < ApplicationRecord
  include Ownerable
  include Creatorable

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

  has_many :comments

  has_one_attached :avatar
  has_one_attached :cropped_avatar

  has_many :permissions, as: :actorable, class_name: "Permission"

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


  def has_resource_modify_permissions?(entity)
    if entity.class == Articles::Article
      permissions = entity.permissions
      correlated_permissions = permissions.select {|permission| permission.actorable == self}
      permissions = correlated_permissions.select {|permission| modify_permissions.include?(permission.allowed_action_type)}
      permissions.any?
    elsif entity.class == Units::Unit
      permissions = entity.permissions
      correlated_permissions = permissions.select {|permission| permission.actorable == self}
      permissions = correlated_permissions.select {|permission| modify_permissions.include?(permission.allowed_action_type)}
      permissions.any?
    elsif entity.class == Algorithms::Algorithm
      permissions = entity.permissions
      correlated_permissions = permissions.select {|permission| permission.actorable == self}
      permissions = correlated_permissions.select {|permission| modify_permissions.include?(permission.allowed_action_type)}
      permissions.any?
    elsif entity.class == CheatSheets::CheatSheet
      permissions = entity.permissions
      correlated_permissions = permissions.select {|permission| permission.actorable == self}
      permissions = correlated_permissions.select {|permission| modify_permissions.include?(permission.allowed_action_type)}
      permissions.any?
    elsif entity.class == CheatSheetGroups::CheatSheetGroup
      permissions = entity.permissions
      correlated_permissions = permissions.select {|permission| permission.actorable == self}
      permissions = correlated_permissions.select {|permission| modify_permissions.include?(permission.allowed_action_type)}
      permissions.any?
    elsif entity.class == SimpleClasses::ClassContainer
      class_layer_entity = entity.related_class_layer_entity
      permissions = class_layer_entity.permissions
      correlated_permissions = permissions.select {|permission| permission.actorable == self}
      permissions = correlated_permissions.select {|permission| modify_permissions.include?(permission.allowed_action_type)}
      permissions.any?
    elsif entity.class == SimpleClasses::InterfaceGroup
      binding.pry
      class_layer_entity = entity.related_class_layer_entity
      permissions = class_layer_entity.permissions
      correlated_permissions = permissions.select {|permission| permission.actorable == self}
      permissions = correlated_permissions.select {|permission| modify_permissions.include?(permission.allowed_action_type)}
      permissions.any?
    elsif entity.class == SimpleClasses::SimpleClass
      permissions = entity.permissions
      correlated_permissions = permissions.select {|permission| permission.actorable == self}
      permissions = correlated_permissions.select {|permission| modify_permissions.include?(permission.allowed_action_type)}
      permissions.any?
    elsif entity.class == Frameworks::Framework
      permissions = entity.permissions
      correlated_permissions = permissions.select {|permission| permission.actorable == self}
      permissions = correlated_permissions.select {|permission| modify_permissions.include?(permission.allowed_action_type)}
      permissions.any?
    end
  end

  def modify_permissions
    [Permissions::AllowedActionTypes[:all_actions], Permissions::AllowedActionTypes[:modify]]
  end
end
