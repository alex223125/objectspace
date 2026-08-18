# app/controllers/admin/support_messages_controller.rb
class Admin::SupportMessagesController < AdminController
  def index
    # --------------------------------------------------------
    # STATISTICS
    # --------------------------------------------------------

    @total_messages =
      SupportMessage.count

    @confirmed_messages =
      SupportMessage.where.not(email_confirmed_at: nil).count

    @pending_messages =
      SupportMessage.where(
        status: "pending_confirmation"
      ).count

    @financial_support_messages =
      SupportMessage.where(
        support_category: financial_support_categories
      ).count

    # --------------------------------------------------------
    # Your existing message listing code goes here.
    # Keep your existing pagination / infinity-scroll logic.
    # --------------------------------------------------------

    # --------------------------------------------------------
    # BASE QUERY
    # --------------------------------------------------------

    messages = SupportMessage.all


    # --------------------------------------------------------
    # GENERAL SEARCH
    #
    # Searches:
    # first name
    # last name
    # email
    # organisation
    # message
    # --------------------------------------------------------

    if params[:q].present?

      query = SupportMessage.sanitize_sql_like(
        params[:q].to_s.strip
      )

      search_pattern = "%#{query}%"

      messages = messages.where(
        "first_name LIKE :search
           OR last_name LIKE :search
           OR email LIKE :search
           OR organisation LIKE :search
           OR message LIKE :search",
        search: search_pattern
      )

    end


    # --------------------------------------------------------
    # STATUS
    # --------------------------------------------------------

    if params[:status].present? &&
      SupportMessage::STATUSES.key?(params[:status])

      messages =
        messages.where(
          status: params[:status]
        )

    end


    # --------------------------------------------------------
    # EMAIL CONFIRMATION
    #
    # confirmed
    # pending
    # --------------------------------------------------------

    case params[:email_confirmation]

    when "confirmed"

      messages =
        messages.where.not(
          email_confirmed_at: nil
        )

    when "pending"

      messages =
        messages.where(
          email_confirmed_at: nil
        )

    end


    # --------------------------------------------------------
    # SUPPORT CATEGORY
    # --------------------------------------------------------

    if params[:support_category].present? &&
      SupportMessage::SUPPORT_CATEGORIES.key?(
        params[:support_category]
      )

      messages =
        messages.where(
          support_category: params[:support_category]
        )

    end


    # --------------------------------------------------------
    # SOURCE / HOW THEY HEARD ABOUT PROJECT
    # --------------------------------------------------------

    if params[:source].present? &&
      SupportMessage::DISCOVERY_SOURCES.key?(
        params[:source]
      )

      messages =
        messages.where(
          source: params[:source]
        )

    end


    # --------------------------------------------------------
    # ATTACHMENTS
    #
    # has_attachments
    # no_attachments
    # --------------------------------------------------------

    case params[:attachments]

    when "has"

      messages =
        messages.joins(:attachments_attachments).distinct

    when "none"

      messages =
        messages.where.not(
          id: ActiveStorage::Attachment
                .where(
                  record_type: "SupportMessage",
                  name: "attachments"
                )
                .select(:record_id)
        )

    end


    # --------------------------------------------------------
    # CREATED FROM DATE
    # --------------------------------------------------------

    if valid_date?(params[:created_from])

      created_from =
        Date.parse(params[:created_from])

      messages =
        messages.where(
          "created_at >= ?",
          created_from.beginning_of_day
        )

    end


    # --------------------------------------------------------
    # CREATED TO DATE
    # --------------------------------------------------------

    if valid_date?(params[:created_to])

      created_to =
        Date.parse(params[:created_to])

      messages =
        messages.where(
          "created_at <= ?",
          created_to.end_of_day
        )

    end


    # --------------------------------------------------------
    # UPDATED FROM DATE
    # --------------------------------------------------------

    if valid_date?(params[:updated_from])

      updated_from =
        Date.parse(params[:updated_from])

      messages =
        messages.where(
          "updated_at >= ?",
          updated_from.beginning_of_day
        )

    end


    # --------------------------------------------------------
    # UPDATED TO DATE
    # --------------------------------------------------------

    if valid_date?(params[:updated_to])

      updated_to =
        Date.parse(params[:updated_to])

      messages =
        messages.where(
          "updated_at <= ?",
          updated_to.end_of_day
        )

    end


    # --------------------------------------------------------
    # SORTING
    # --------------------------------------------------------

    sort_columns = {
      "newest"         => { created_at: :desc },
      "oldest"         => { created_at: :asc },
      "recently_updated" => { updated_at: :desc },
      "least_recently_updated" => { updated_at: :asc },
      "first_name"     => { first_name: :asc },
      "last_name"      => { last_name: :asc },
      "email"          => { email: :asc },
      "organisation"   => { organisation: :asc }
    }


    sort_key =
      params[:sort].presence || "newest"


    sort_order =
      sort_columns[sort_key] ||
        sort_columns["newest"]


    # --------------------------------------------------------
    # DIRECTION
    #
    # Allows the user to reverse the selected sort.
    # --------------------------------------------------------

    if params[:direction] == "asc"

      column =
        sort_order.keys.first

      sort_order =
        { column => :asc }

    elsif params[:direction] == "desc"

      column =
        sort_order.keys.first

      sort_order =
        { column => :desc }

    end


    messages =
      messages.order(sort_order)


    # --------------------------------------------------------
    # SECONDARY SORT
    #
    # Makes pagination deterministic when many records have
    # identical timestamps.
    # --------------------------------------------------------

    messages =
      messages.order(id: :desc)


    # --------------------------------------------------------
    # RESULTS PER PAGE
    # --------------------------------------------------------

    allowed_per_page = [
      10,
      20,
      30,
      50,
      100
    ]

    @per_page =
      params[:per_page].to_i

    @per_page =
      20 unless allowed_per_page.include?(@per_page)


    # --------------------------------------------------------
    # PAGINATION
    #
    # This works with Kaminari.
    # --------------------------------------------------------

    @messages = messages.page(params[:page]).per(@per_page)

    # --------------------------------------------------------
    # FILTER STATE FOR VIEW
    # --------------------------------------------------------

    @active_filter_count =
      count_active_filters


    # --------------------------------------------------------
    # INFINITY SCROLL REQUEST
    # --------------------------------------------------------

    if params[:infinite_scroll].present?

      render partial: "message",
             collection: @messages,
             as: :message,
             locals: {
               offset: (@messages.current_page - 1) *
                 @messages.limit_value
             }

      return
    end


    # if params[:infinite_scroll].present?
    #   render partial: "admin/support_messages/message_rows",
    #          locals: { messages: @messages }
    # end
  end

  def show
    @message = SupportMessage.find(params[:id])
  end

  def update
    @message = SupportMessage.find(params[:id])
    if @message.update(support_message_params)
      redirect_to admin_support_message_path(@message),
                  notice: "Message updated successfully."
    else
      render :show,
             status: :unprocessable_entity

    end
  end

  private

  # ==========================================================
  # FINANCIAL CATEGORIES
  # ==========================================================

  def financial_support_categories
    %w[
        bank_transfer
        paypal
        stripe
        crypto
        sponsorship
        grant
        corporate
        private_donation
      ]
  end


  # ==========================================================
  # DATE VALIDATION
  # ==========================================================

  def valid_date?(value)
    return false if value.blank?
    Date.parse(value.to_s)
    true
  rescue ArgumentError
    false
  end


  # ==========================================================
  # ACTIVE FILTER COUNTER
  # ==========================================================

  def count_active_filters
    filter_keys = [
      :q,
      :status,
      :email_confirmation,
      :support_category,
      :source,
      :attachments,
      :created_from,
      :created_to,
      :updated_from,
      :updated_to
    ]

    filter_keys.count do |key|
      params[key].present?
    end
  end

  # ==========================================================
  # STRONG PARAMETERS
  # ==========================================================

  def support_message_params
    params.require(:support_message)
          .permit(
            :status
          )

  end
end