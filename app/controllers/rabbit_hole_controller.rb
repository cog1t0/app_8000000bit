class RabbitHoleController < ApplicationController
  before_action :authenticate_rabbit_hole!, only: [ :form ]

  def form
    # テストフォーム表示用（Basic認証必要）
  end

  def create
    # パラメータ取得
    year = params[:year].to_i
    month = params[:month].to_i
    day = params[:day].to_i
    sex = params[:sex]
    fortune_type = params[:type]
    memo = params[:memo]

    # 命式データ取得
    master = MeishikiFetcher.fetch(year: year, month: month, day: day, sex: sex)

    # AI診断実行
    ai_result = DiagnosisAiService.call(master, type: fortune_type, memo: memo)

    # 診断結果保存
    token = SecureRandom.urlsafe_base64(32)
    tmp_code = format("%04d", SecureRandom.random_number(10_000))
    diagnosis = DiagnosisResult.create!(
      token: token,
      meishiki_master: master,
      fortune_type: fortune_type,
      memo: memo,
      ai_summary: ai_result["summary"],
      ai_advice: ai_result["advice"],
      accessed: false,
      tmp_password: tmp_code,
      tmp_password_expires_at: 5.minutes.from_now
    )

    # セッションにトークン保存
    session[:token] = token

    # created ページで表示する値をセッション経由で渡す
    session[:created_token] = token
    session[:created_code] = tmp_code
    session[:created_expires_at] = diagnosis.tmp_password_expires_at
    # PRG: GET にリダイレクト（Turbo含め確実な画面遷移）
    redirect_to rabbit_hole_created_path
  end

  def created
    @token = session.delete(:created_token)
    @code = session.delete(:created_code)
    expires_raw = session.delete(:created_expires_at)
    @expires_at = if expires_raw.is_a?(Time) || defined?(ActiveSupport::TimeWithZone) && expires_raw.is_a?(ActiveSupport::TimeWithZone)
      expires_raw
    else
      # セッションでシリアライズされた文字列をTimeに戻す
      begin
        Time.zone ? Time.zone.parse(expires_raw.to_s) : Time.parse(expires_raw.to_s)
      rescue
        nil
      end
    end
    unless @token && @code && @expires_at
      redirect_to rabbit_hole_form_path, alert: "作成情報が見つかりません"
      return
    end
  end

  def show
    # 結果表示（トークン or 4桁コード）
    token = params[:token] || session[:token]
    code  = params[:code]&.to_s&.strip

    # まずトークンで取得
    @result = DiagnosisResult.find_by(token: token) if token.present?

    # トークンが無ければコード入力ページを見せる
    if @result.nil? && code.blank?
      render :enter_code
      return
    end

    # コードでのアクセス（別端末でもOK）。未失効の最新1件。
    if @result.nil? && code.present?
      @result = DiagnosisResult.where(tmp_password: code)
                               .order(created_at: :desc)
                               .first
      unless @result
        @hint_expires_at = nil
        @code_error = "コードが正しくありません"
        render :enter_code, status: :unprocessable_entity
        return
      end
      if @result.tmp_password_expires_at.present? && Time.current > @result.tmp_password_expires_at
        @hint_expires_at = @result.tmp_password_expires_at
        @code_error = "コードの有効期限が切れています"
        render :enter_code, status: :unprocessable_entity
        return
      end
      # コードアクセスはセッション不要で閲覧可（5分以内）
    end

    unless @result
      render plain: "診断結果が見つかりません", status: :not_found
      return
    end

    # トークン閲覧は作成から5分まで。それ以降はセッション一致時のみ。
    @expired = @result.created_at < 5.minutes.ago
    @can_view = true
    if token.present?
      @can_view = !@expired || session[:token] == token
    end
    unless @can_view
      @hint_expires_at = @result.tmp_password_expires_at
      render :enter_code
      return
    end

    # アクセス記録
    @result.update(accessed: true)
    @master = @result.meishiki_master
  end

  private

  def authenticate_rabbit_hole!
    # formアクションの場合は固定認証
    if action_name == "form"
      authenticate_or_request_with_http_basic("RabbitHole Form") do |username, password|
        username == "riku" && password == "riku1031"
      end
    end
  end
end
