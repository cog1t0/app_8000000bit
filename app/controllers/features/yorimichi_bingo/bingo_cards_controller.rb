module Features
  module YorimichiBingo
    class BingoCardsController < ApplicationController
      before_action :set_bingo_card, only: %i[show toggle reset]
      before_action :set_checker, only: %i[show toggle]

      def start
        @bingo_card = BingoCard.new(title: BoardBuilder::DEFAULT_TITLE)
        @duration_days = BoardBuilder::DEFAULT_DURATION_DAYS
      end

      def create
        @bingo_card = BoardBuilder.new(
          title: start_params[:title],
          duration_days: start_params[:duration_days]
        ).call

        redirect_to yorimichi_bingo_card_path(token: @bingo_card.token)
      rescue ActiveRecord::RecordInvalid => e
        @bingo_card = e.record
        @duration_days = start_params[:duration_days]
        flash.now[:alert] = "カードを作成できませんでした。もう一度お試しください。"
        render :start, status: :unprocessable_entity
      end

      def show; end

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

        redirect_to yorimichi_bingo_card_path(token: new_card.token), notice: "新しいびんごカードを作りました！"
      end

      private

      def start_params
        params.fetch(:bingo_card, {}).permit(:title, :duration_days)
      end

      def set_bingo_card
        @bingo_card = BingoCard.find_by!(token: params[:token])
        @share_url = "#{request.base_url}#{yorimichi_bingo_card_path(token: @bingo_card.token)}"
      end

      def set_checker
        @checker = BingoChecker.new(@bingo_card)
      end
    end
  end
end
