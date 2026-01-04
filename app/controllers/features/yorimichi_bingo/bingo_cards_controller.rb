module Features
  module YorimichiBingo
    class BingoCardsController < ApplicationController
      before_action :set_bingo_card, only: %i[show toggle reset edit update]
      before_action :ensure_setup_completed!, only: %i[show toggle]
      before_action :set_checker, only: %i[show toggle]
      before_action :ensure_setup_pending!, only: %i[edit update]

      def start
      end

      def create
        @bingo_card = BoardBuilder.new(title: BoardBuilder::DEFAULT_TITLE).call
        @bingo_card.update!(setup_completed_at: nil, selected_category_slugs: [])

        redirect_to yorimichi_bingo_edit_path(token: @bingo_card.token)
      rescue ActiveRecord::RecordInvalid => e
        flash.now[:alert] = "カードを作成できませんでした。もう一度お試しください。"
        @error_messages = e.record.errors.full_messages
        render :start, status: :unprocessable_entity
      end

      def show; end

      def edit
        load_categories
        @duration_days = default_duration_days
        @selected_category_slugs = @bingo_card.selected_category_slugs.presence || []
      end

      def update
        load_categories
        selected_slugs = Array(setup_params[:category_slugs]).reject(&:blank?)
        duration_days = normalized_duration_days(setup_params[:duration_days])
        title = setup_params[:title].presence || BoardBuilder::DEFAULT_TITLE

        items = BoardBuilder.items_for_category_slugs(selected_slugs)

        ActiveRecord::Base.transaction do
          @bingo_card.update!(
            title: title,
            items: items,
            expires_at: duration_days.days.from_now,
            selected_category_slugs: selected_slugs,
            setup_completed_at: Time.current
          )
        end

        redirect_to yorimichi_bingo_card_path(token: @bingo_card.token), notice: "カードが完成しました！共有URLをみんなに届けよう。"
      rescue BoardBuilder::CategorySelectionError => e
        flash.now[:alert] = e.message
        @duration_days = duration_days
        @selected_category_slugs = selected_slugs
        render :edit, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => e
        flash.now[:alert] = e.record.errors.full_messages.to_sentence
        @duration_days = duration_days
        @selected_category_slugs = selected_slugs
        render :edit, status: :unprocessable_entity
      end

      def toggle
        if @bingo_card.expired?
          message = "期限が切れたカードは更新できません。"
          flash.now[:alert] = message
          flash[:alert] = message
          respond_to do |format|
            format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "features/yorimichi_bingo/bingo_cards/flash") }
            format.html { redirect_to yorimichi_bingo_card_path(token: @bingo_card.token) }
          end
          return
        end

        Toggler.new(@bingo_card, params[:id]).call
        @checker = BingoChecker.new(@bingo_card)

        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to yorimichi_bingo_card_path(token: @bingo_card.token) }
        end
      end

      def reset
        new_card = BoardBuilder.new(
          title: @bingo_card.title,
          duration_days: BoardBuilder::DEFAULT_DURATION_DAYS
        ).call

        new_card.update!(setup_completed_at: nil, selected_category_slugs: [])

        redirect_to yorimichi_bingo_edit_path(token: new_card.token), notice: "新しいカードを作りました。カテゴリを選び直してスタートしよう！"
      end

      private

      def set_bingo_card
        @bingo_card = BingoCard.find_by!(token: params[:token])
        @share_url = "#{request.base_url}#{yorimichi_bingo_card_path(token: @bingo_card.token)}"
      end

      def set_checker
        @checker = BingoChecker.new(@bingo_card)
      end

      def load_categories
        @categories = BingoCategory.includes(:bingo_items).order(:display_name)
      end

      def default_duration_days
        ((@bingo_card.expires_at - Time.current) / 1.day).ceil.clamp(1, 120)
      rescue StandardError
        BoardBuilder::DEFAULT_DURATION_DAYS
      end

      def setup_params
        params.fetch(:setup, {}).permit(:title, :duration_days, category_slugs: [])
      end

      def normalized_duration_days(value)
        days = value.to_i
        days = BoardBuilder::DEFAULT_DURATION_DAYS if days <= 0
        [days, 120].min
      end

      def ensure_setup_completed!
        return if @bingo_card.setup_completed_at.present?

        redirect_to yorimichi_bingo_edit_path(token: @bingo_card.token), alert: "まずはカテゴリを選んでカードを完成させてください。"
      end

      def ensure_setup_pending!
        return if @bingo_card.setup_completed_at.blank?

        redirect_to yorimichi_bingo_card_path(token: @bingo_card.token), alert: "このカードはすでにセットアップ済みです。"
      end
    end
  end
end
