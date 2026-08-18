# app/models/support_message.rb
class SupportMessage < ApplicationRecord
  has_many_attached :attachments

  SUPPORT_CATEGORIES = {
    "bank_transfer" => "Bank Transfer",
    "paypal" => "PayPal",
    "stripe" => "Stripe",
    "crypto" => "Cryptocurrency",
    "sponsorship" => "Sponsorship",
    "grant" => "Grant / Funding",
    "corporate" => "Corporate Support",
    "private_donation" => "Private Donation",
    "other" => "Other"
  }.freeze

  REFERRAL_SOURCES = {
    "google" => "Google / Search Engine",
    "social_media" => "Social Media",
    "youtube" => "YouTube",
    "reddit" => "Reddit",
    "github" => "GitHub",
    "friend" => "Friend / Recommendation",
    "article" => "Another Article",
    "newsletter" => "Newsletter",
    "direct" => "I found the website directly",
    "other" => "Other"
  }.freeze

  # ==========================================================
  # PROJECT DISCOVERY SOURCES
  # ==========================================================

  DISCOVERY_SOURCES = {
    "google"          => "Google Search",
    "bing"            => "Bing Search",
    "social_media"    => "Social Media",
    "facebook"        => "Facebook",
    "instagram"       => "Instagram",
    "linkedin"        => "LinkedIn",
    "youtube"         => "YouTube",
    "reddit"          => "Reddit",
    "friend"          => "Friend / Colleague",
    "community"       => "Community / Forum",
    "news"            => "News / Article",
    "event"           => "Event / Conference",
    "other"           => "Other"
  }.freeze

  STATUSES = {
    "pending_confirmation" => "Pending Email Confirmation",
    "confirmed" => "Confirmed",
    "read" => "Read",
    "replied" => "Replied",
    "archived" => "Archived"
  }.freeze

  enum :status, {
    pending_confirmation: "pending_confirmation",
    confirmed: "confirmed",
    read: "read",
    replied: "replied",
    archived: "archived"
  }

  def source_label
    self.class::DISCOVERY_SOURCES.to_h[source] ||
      source.to_s.humanize
  end

  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :email, presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :support_category, inclusion: { in: SUPPORT_CATEGORIES.keys }
  validates :referral_source,
            inclusion: { in: REFERRAL_SOURCES.keys },
            allow_blank: true

  validates :message, presence: true

  validates :status, presence: true
  validates :status,
            inclusion: {
              in: STATUSES.keys
            }


  before_create :generate_email_confirmation_token

  scope :confirmed, -> {
    where.not(email_confirmed_at: nil)
  }

  scope :pending_confirmation, -> {
    where(email_confirmed_at: nil)
  }

  def email_confirmed?
    email_confirmed_at.present?
  end

  def human_verified?
    human_verified_at.present?
  end

  def support_category_label
    SUPPORT_CATEGORIES[support_category] || support_category
  end

  def referral_source_label
    REFERRAL_SOURCES[referral_source] || referral_source
  end

  def status_label
    STATUSES[status] || status
  end

  def confirm_email!
    update!(
      email_confirmed_at: Time.current,
      status: "confirmed"
    )
  end

  validate :validate_attachments

  MAX_ATTACHMENT_SIZE = 10.megabytes
  ALLOWED_ATTACHMENT_TYPES = %w[
  image/png
  image/jpeg
  image/webp
  image/gif
].freeze

  private

  def generate_email_confirmation_token
    self.email_confirmation_token ||= SecureRandom.urlsafe_base64(48)
    self.status ||= "pending_confirmation"
  end

  def validate_attachments
    attachments.each do |attachment|
      unless ALLOWED_ATTACHMENT_TYPES.include?(attachment.content_type)
        errors.add(
          :attachments,
          "#{attachment.filename} is not a supported image"
        )
      end

      if attachment.byte_size > MAX_ATTACHMENT_SIZE
        errors.add(
          :attachments,
          "#{attachment.filename} is too large"
        )
      end
    end
  end
end