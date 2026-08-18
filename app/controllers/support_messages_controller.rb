# app/controllers/support_messages_controller.rb

class SupportMessagesController < ApplicationController
  before_action :prepare_puzzle, only: [:new]

  def new
    @support_message = SupportMessage.new
  end

  def create
    unless human_puzzle_valid?
      @support_message = SupportMessage.new(support_message_params)

      prepare_puzzle

      flash.now[:alert] =
        "Please complete the human verification puzzle correctly."

      render :new, status: :unprocessable_entity
      return
    end

    @support_message = SupportMessage.new(support_message_params)

    @support_message.ip_address = request.remote_ip
    @support_message.user_agent = request.user_agent
    @support_message.human_verified_at = Time.current

    if @support_message.save
      SupportMessageMailer.email_confirmation(
        @support_message
      ).deliver_later

      session.delete(:support_puzzle)

      redirect_to financial_support_path,
                  notice: "Your message has been received. Please check your email to confirm it."
    else
      prepare_puzzle
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    @support_message =
      SupportMessage.find_by(
        email_confirmation_token: params[:token]
      )

    if @support_message.nil?
      redirect_to financial_support_path,
                  alert: "This confirmation link is invalid."
      return
    end

    if @support_message.email_confirmed?
      redirect_to financial_support_path,
                  notice: "Your email address has already been confirmed."
      return
    end

    @support_message.confirm_email!

    redirect_to financial_support_path,
                notice: "Thank you. Your email address has been confirmed."
  end

  private

  def support_message_params
    params.require(:support_message).permit(
      :first_name,
      :last_name,
      :organization_name,
      :email,
      :support_category,
      :referral_source,
      :message,
      attachments: []
    )
  end

  def prepare_puzzle
    @puzzle_sequence = (0..8).to_a.shuffle

    session[:support_puzzle] = {
      sequence: @puzzle_sequence,
      expires_at: 10.minutes.from_now.to_i
    }
  end

  def human_puzzle_valid?
    puzzle = session[:support_puzzle]

    return false if puzzle.blank?
    return false if puzzle["expires_at"].to_i < Time.current.to_i

    submitted =
      Array(params[:puzzle_order]).map(&:to_i)

    expected =
      puzzle["sequence"].map(&:to_i)

    ActiveSupport::SecurityUtils.secure_compare(
      submitted.join(","),
      expected.join(",")
    )
  end
end