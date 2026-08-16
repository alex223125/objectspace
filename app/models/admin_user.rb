class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validates presence of Name
  validates :name, presence: true

  # Strict Username Validation matching your hint instructions
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: {
              with: /\A[A-Za-z0-9]+([_.-][A-Za-z0-9]+)*\z/,
              message: "can only contain letters, numbers, and single internal hyphens/underscores/dots"
            }


  # 1. Create a virtual attribute for form data mapping
  attr_accessor :tos_agreement
  # 2. Add validation to ensure the box MUST be checked on signup
  validates :tos_agreement, acceptance: { message: "must be accepted to create an account" }
end
