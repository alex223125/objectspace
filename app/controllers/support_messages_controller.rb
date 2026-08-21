# app/controllers/support_messages_controller.rb

class SupportMessagesController < ApplicationController
  before_action :prepare_puzzle, only: [:new]

  def new
    @support_message = SupportMessage.new
  end

  def create
    binding.pry
    unless human_puzzle_valid?

      binding.pry
      @support_message = SupportMessage.new(support_message_params)

      binding.pry
      prepare_puzzle

      flash.now[:alert] =
        # if @current_puzzle.blank?
        #   "Human verification session is missing. Please try again."
        # elsif @current_puzzle["expires_at"].to_i < Time.current.to_i
        #   "Human verification has expired. Please try again."
        # elsif params[:puzzle_position].blank?
        #   "Please move the slider to complete human verification."
        # else
        #   "Human verification failed. Please try again."
        # end

      # 1. No puzzle in session
      if @current_puzzle.blank?
        @human_puzzle_error =
          "Human verification could not be found. Please refresh the page and try again."
        return false
      end

      # 2. Puzzle expired
      if @current_puzzle["expires_at"].blank?
        @human_puzzle_error =
          "Human verification has no expiration time. Please refresh the page and try again."
        return false
      end

      if @current_puzzle["expires_at"].to_i < Time.current.to_i
        session.delete(:support_puzzle)

        @human_puzzle_error =
          "Your human verification has expired. Please complete the new verification."
        return false
      end

      # 3. Target position missing
      if @current_puzzle["target_position"].blank?
        @human_puzzle_error =
          "Human verification is incomplete. Please refresh the page and try again."
        return false
      end

      # 4. Slider parameter missing
      if params[:puzzle_position].blank?
        @human_puzzle_error =
          "Please move the verification slider before submitting the form."
        return false
      end

      # 5. Slider parameter is not numeric
      unless params[:puzzle_position].to_s.match?(/\A\d+\z/)
        @human_puzzle_error =
          "The verification slider contains an invalid value. Please try again."
        return false
      end

      submitted = params[:puzzle_position].to_i
      expected = @current_puzzle["target_position"].to_i

      # 6. Submitted value outside reasonable slider range
      if submitted < 0 || submitted > 100
        @human_puzzle_error =
          "The verification slider position is invalid. Please try again."
        return false
      end

      difference = (submitted - expected).abs

      # 7. Incorrect position
      unless difference <= 30
        @human_puzzle_error =
          "Human verification failed. Please move the slider closer to the target."
        return false
      end

      # 8. Everything is correct
      true

      binding.pry
      render :new, status: :unprocessable_entity
      return
    end

    binding.pry
    @support_message = SupportMessage.new(support_message_params)

    binding.pry
    @support_message.ip_address = request.remote_ip
    @support_message.user_agent = request.user_agent
    @support_message.human_verified_at = Time.current

    binding.pry
    if @support_message.save

      binding.pry
      SupportMessageMailer.email_confirmation(
        @support_message
      ).deliver_later

      binding.pry
      session.delete(:support_puzzle)

      binding.pry
      redirect_to financial_page_path,
                  notice: "Your message has been received. Please check your email to confirm it."
    else
      binding.pry
      prepare_puzzle

      binding.pry
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    @support_message =
      SupportMessage.find_by(
        email_confirmation_token: params[:token]
      )

    if @support_message.nil?
      redirect_to financial_page_path,
                  alert: "This confirmation link is invalid."
      return
    end

    if @support_message.email_confirmed?
      redirect_to financial_page_path,
                  notice: "Your email address has already been confirmed."
      return
    end

    @support_message.confirm_email!

    redirect_to financial_page_path,
                notice: "Thank you. Your email address has been confirmed."
  end

  private

  # def support_message_params
  #   # Safely extract incoming key variants arriving from the frontend interface form fields
  #   incoming_source = params[:support_message][:discovery_source] || params[:support_message][:referral_source]
  #
  #   params.require(:support_message).permit(
  #     :first_name,
  #     :last_name,
  #     :organization_name,
  #     :email,
  #     :support_category,
  #     :message,
  #     attachments: []
  #   ).merge(referral_source: incoming_source) # Map the value down explicitly to match the ActiveRecord schema model
  # end

  private

  # def support_message_params
  #   # Дазваляем discovery_source, каб не было папярэджанняў у логах
  #   permitted = params.require(:support_message).permit(
  #     :first_name,
  #     :last_name,
  #     :organization_name,
  #     :email,
  #     :support_category,
  #     :discovery_source,
  #     :message,
  #     attachments: []
  #   )
  #
  #   source_value = permitted[:discovery_source]
  #
  #   permitted.delete(:discovery_source)
  #   permitted.merge(referral_source: source_value)
  # end

  # ============================================================
  # NEW PROTONMAIL-STYLE INTERACTION PREPARATION
  # ============================================================
  # def prepare_puzzle
  #   binding.pry
  #   if session[:support_puzzle].present? && session[:support_puzzle]["expires_at"].to_i > Time.current.to_i
  #
  #     binding.pry
  #     @puzzle_target_position = session[:support_puzzle]["target_position"].to_i
  #   else
  #
  #     binding.pry
  #     target_position = rand(30..75)
  #     session[:support_puzzle] = {
  #       "target_position" => target_position,
  #       "expires_at" => 15.minutes.from_now.to_i
  #     }
  #     @puzzle_target_position = target_position
  #   end
  # end

  # ============================================================
  # REAL NUMERIC POSITION DISTANCE SLIDER VERIFIER
  # ============================================================
  # def human_puzzle_valid?
  #   puzzle = session[:support_puzzle]
  #   return false if puzzle.blank?
  #   return false if puzzle["expires_at"].to_i < Time.current.to_i
  #
  #   # Fallback to true if checking is bypassed, otherwise evaluate real numeric data points
  #   return true if puzzle["target_position"].blank?
  #
  #   submitted = params[:puzzle_position].to_i
  #   expected = puzzle["target_position"].to_i
  #
  #   # Allow a minor tolerance margin of +/- 8 units for natural human hand imprecision
  #   (submitted - expected).abs <= 8
  # end
  # def human_puzzle_valid?
  #   binding.pry
  #   puzzle = session[:support_puzzle]
  #   return false if puzzle.blank?
  #   return false if puzzle["expires_at"].to_i < Time.current.to_i
  #
  #   binding.pry
  #   submitted = params[:puzzle_position].to_i
  #   expected = puzzle["target_position"].to_i
  #
  #   binding.pry
  #   (submitted - expected).abs <= 8
  # end


  private

  # ============================================================
  # СТРАНГ-ПАРАМЕТРЫ З АЎТАМАЦЫЧНЫМ МАПІНГAM КАЛОНАК
  # ============================================================
  def support_message_params
    binding.pry
    permitted = params.require(:support_message).permit(
      :first_name,
      :last_name,
      :organization_name,
      :email,
      :support_category,
      :discovery_source,
      :message,
      attachments: []
    )

    source_value = permitted[:discovery_source]
    permitted.delete(:discovery_source)
    permitted.merge(referral_source: source_value)
  end

  # ============================================================
  # НАДЗЕЙНАЯ ПАДРЫХТОЎКА СЕСІІ ПАЗЛА (ПЕРАЗАПІС ПРАТЭРМІНАВАНАГА)
  # ============================================================
  def prepare_puzzle
    binding.pry
    @current_puzzle = session[:support_puzzle]


    binding.pry
    # Калі сесія існуе, змяшчае новы ключ і час яшчэ не выйшаў — выкарыстоўваем яе
    if @current_puzzle.present? && @current_puzzle["target_position"].present? && @current_puzzle["expires_at"].to_i > Time.current.to_i
      @puzzle_target_position = @current_puzzle["target_position"].to_i
    else
      binding.pry
      # У адваротным выпадку (няма сесіі, яна састарэла або гэта стары фармат 3x3) — ствараем наваку
      target_position = rand(35..75)

      session[:support_puzzle] = {
        "target_position" => target_position,
        "expires_at" => 15.minutes.from_now.to_i
      }
      @puzzle_target_position = target_position
    end
  end

  # ============================================================
  # ВАЛІДАЦЫЯ ДЛЯ СЛАЙДЭРА З АБНАЎЛЕННЕМ ЧАСУ СЕСІІ
  # ============================================================
  def human_puzzle_valid?
    binding.pry
    puzzle = session[:support_puzzle]

    binding.pry
    return false if puzzle.blank?

    binding.pry
    # Калі час выйшаў — выдаляем сесію і вяртаем false, каб выклікаць перазапуск капчы
    # if puzzle["expires_at"].to_i < Time.current.to_i
    if puzzle["expires_at"].to_i < Time.current.to_i
      binding.pry
      session.delete(:support_puzzle)
      return false
    end

    binding.pry
    # Бяспечная праверка: калі па нейкай прычыне ключа няма (старая сесія), не пускаем бота
    return false if puzzle["target_position"].blank?

    binding.pry
    submitted = params[:puzzle_position].to_i
    binding.pry
    expected = puzzle["target_position"].to_i

    binding.pry
    # Хібнасць у +/- 8 адзінак для камфортнага перацягвання
    (submitted - expected).abs <= 30
  end
end