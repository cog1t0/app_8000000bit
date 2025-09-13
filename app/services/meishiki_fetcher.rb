# 情報の取得元
# https://chi92.suinavi.com/index.php
# HTTPメソッド：POST
# パラメーター
# dat_year：生年月日の年
# dat_month：生年月日の月
# dat_day：生年月日の日
# dat_sex：性別（1: 男性, 2: 女性）
# ctype：1で固定
# skbn：1で固定
# URL例
# https://chi92.suinavi.com/index.php?dat_year=1989&dat_month=11&dat_day=9& dat_sex=2& ctype=1&skbn=1

# レスポンス例
# <!DOCTYPE html><html xmlns:og="http://ogp.me/ns#">
# <head>
# 	<title>鳥海流四柱推命</title>
# 	<meta charset="UTF-8" >
# 	<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
# 	<script src="./jquery-3.2.1.min.js"></script>
# 	<script>


# 	(function(){
# 	    var _UA = navigator.userAgent;
# 	    if (_UA.indexOf('iPhone') > -1 || _UA.indexOf('iPod') > -1) {
# 	        document.write('<link href="./top_ios.css?xxx=20170221003" rel="stylesheet" type="text/css" media="all" >');
# 	    }else if(_UA.indexOf('Android') > -1){
# 	        document.write('<link href="./top.css?xxx=20170221003" rel="stylesheet" type="text/css" media="all" >');
# 	    }else{
# 	        document.write('<link href="./top.css?xxx=20170221003" rel="stylesheet" type="text/css" media="all" >');
# 	    }
# 	})();

# 	// documentが読み込まれたあとの共通処理
# 	$(document).ready(function(){
# 		// HTMLの横幅を指定する。
# 		var HTML_WIDTH = "700";

# 		$(function() {
# 		    $(window).resize(function(){ setZoom() });
# 		    setZoom();
# 		});

# 		function setZoom(){
# 		    var scale = $(window).width() / HTML_WIDTH * 100 + "%";
# 		    $('html').css({'zoom' : scale });
# 		}
# 	});

# 	</script>
# </head>
# <body>
# <div id="wrapper2">
# <div id="head_spacer"></div>
# <div id="head_logo2"></div>
# <div id="detail_frame_base">
# 	<div id="detail_frame_top">
# 		<div class="birth_area_margin"></div>
# 		<div class="birth_area">
# 			1989年
# 			11月
# 			9日
# 			(10時0分)
# 			&nbsp;生&nbsp;

# 			女性		</div>
# 	</div>
# 	<div id="detail_frame_body">
# <!--		<div id="detail_frame_left"></div>-->
# 		<div id="detail_frame_mid">

# 			<div id="detail_title">
# 			<div id="detail_title_1">
# 			</div>
# 			<div id="detail_title_2">
# 			</div>
# 			<div id="detail_title_3">
# 			</div>
# 			<div id="detail_title_4">
# 			</div>
# 			<div id="detail_title_5">
# 			</div>
# 			</div>

# 			<div id="detail_mid_left">

# 				<div class="tenchu">

# 					<div>
# 				戌亥
# 					</div>
# 					<div>
# 				戌亥
# 					</div>

# 				</div>

# 				<div class="kanshi">

# 					<div class="day">
# 						<div class="k_info_1">-水</div>
# 						<div class="k_info_2">癸酉</div>
# 						<div class="k_info_3">-金</div>
# 					</div>

# 					<div class="month">
# 						<div class="k_info_1">-木</div>
# 						<div class="k_info_2">乙亥</div>
# 						<div class="k_info_3">-水</div>
# 					</div>

# 					<div class="year">
# 						<div class="k_info_1">-土</div>
# 						<div class="k_info_2">己巳</div>
# 						<div class="k_info_3">-火</div>
# 					</div>
# 				</div>

# 				<div class="clearline"></div>

# 				<div id="d_mid_left">

# 				</div>

# 				<div id="d_mid_right">

# 					<div class="kanshi_no">

# 						<div class="day3">10</div>
# 						<div class="month3">12</div>
# 						<div class="year3">6</div>

# 					</div>

# 					<div class="zokan">

# 						<div class="day2">辛</div>
# 						<div class="month2">甲</div>
# 						<div class="year2">戊</div>

# 					</div>

# 					<div class="tsuhen">

# 						<div class="day2">&nbsp;</div>
# 						<div class="month2">食神</div>
# 						<div class="year2">偏官</div>

# 					</div>

# 					<div class="ztsuhen">

# 						<div class="day2">偏印</div>
# 						<div class="month2">傷官</div>
# 						<div class="year2">正官</div>

# 					</div>

# 					<div class="unsei12">

# 						<div class="day2">病</div>
# 						<div class="month2">帝旺</div>
# 						<div class="year2">胎</div>

# 					</div>

# 				</div>


# 				<div class="energy">

# 					<div class="kei">19</div>
# 					<div class="day2">4</div>
# 					<div class="month2">12</div>
# 					<div class="year2">3</div>

# 				</div>

# 			</div>

# 			<div id="detail_mid_right">

# 				<div id="right_title_1">
# 				</div>
# 				<div id="right_title_2">
# 				</div>
# 				<div id="right_title_3">
# 				</div>
# 				<div id="right_title_4">
# 				</div>
# 				<div id="right_title_5">
# 				</div>
# 				<div id="right_title_6">
# 				</div>

# 			</div>

# 		</div>
# <!--		<div id="detail_frame_right"></div>-->

# 	</div>
# 	<div class="clearline"></div>
# 	<div id="detail_frame_foot">
# 		<a href="http://suimei.hpjt.biz/blog/meishikinomikata/" target="_blank" ><img src="./images/btn02.png" alt="命式の見方は、こちらをクリックしてください。" id="setsumei_btn" ></a>

# 	</div>
# 	<footer>
# 	<a href="http://suimei.hpjt.biz/blog/" target="_blank"><font color="#ffffff">Presented by 株式会社 地球人</font></a>
# 	</footer>

# </div>
# </div>
# </body>
# </html>

# このレスポンスから
# <div class="zokan">

# 						<div class="day2">辛</div>
# 						<div class="month2">甲</div>
# 						<div class="year2">戊</div>

# 					</div>

# 					<div class="tsuhen">

# 						<div class="day2">&nbsp;</div>
# 						<div class="month2">食神</div>
# 						<div class="year2">偏官</div>

# 					</div>

# 					<div class="ztsuhen">

# 						<div class="day2">偏印</div>
# 						<div class="month2">傷官</div>
# 						<div class="year2">正官</div>

# 					</div>

# 					<div class="unsei12">

# 						<div class="day2">病</div>
# 						<div class="month2">帝旺</div>
# 						<div class="year2">胎</div>

# 					</div>
# に注目し、命式情報を抽出する
require "net/http"
require "uri"
require "openssl"

class MeishikiFetcher
  BASE_URL = "https://chi92.suinavi.com/index.php".freeze

  def self.fetch(year:, month:, day:, sex:)
    # 既存データがあれば返す
    master = MeishikiMaster.find_by(year: year, month: month, day: day, sex: sex)
    return master if master

    # 外部HTMLの取得→解析
    html = fetch_html(year:, month:, day:, sex: normalize_sex(sex))
    parsed = parse_html(html)

    MeishikiMaster.create!(
      year: year,
      month: month,
      day: day,
      sex: sex,
      **parsed
    )
  rescue => e
    # 取得や解析に失敗した場合はエラー内容を添えて例外化
    raise(StandardError, "MeishikiFetcher failed: #{e.class}: #{e.message}")
  end

  private

  def self.fetch_html(year:, month:, day:, sex:)
    uri = URI(BASE_URL)
    form = URI.encode_www_form(
      dat_year: year.to_i,
      dat_month: month.to_i,
      dat_day: day.to_i,
      dat_sex: sex.to_s, # 1:男, 2:女
      ctype: 1,
      skbn: 1
    )

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    # 簡易回避/設定: 環境変数で CA バンドル or 検証無効を指定可能にする
    # 1) SSL_CA_FILE: 明示 CA パス
    # 2) MEISHIKI_FETCHER_INSECURE=1 で VERIFY_NONE (開発専用)
    if http.use_ssl?
      debug = ENV["MEISHIKI_FETCHER_SSL_DEBUG"] == "1"
      if ENV["MEISHIKI_FETCHER_INSECURE"] == "1"
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        warn "[MeishikiFetcher][SSL] WARNING: verification disabled (MEISHIKI_FETCHER_INSECURE=1)" if debug
      else
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end

      # Allow multiple CA files separated by ':' (Unix PATH style). Each is added to a store
      if (ca_env = ENV["SSL_CA_FILE"]).present?
        store = OpenSSL::X509::Store.new
        store.set_default_paths
        ca_env.split(":").each do |ca|
          ca = ca.strip
            next if ca.empty?
          unless File.exist?(ca)
            warn "[MeishikiFetcher][SSL] CA file not found: #{ca}" if debug
            next
          end
          begin
            store.add_file(ca)
            warn "[MeishikiFetcher][SSL] Added CA file: #{ca}" if debug
          rescue OpenSSL::X509::StoreError => e
            warn "[MeishikiFetcher][SSL] Failed adding CA file #{ca}: #{e.class}: #{e.message}" if debug
          end
        end
        http.cert_store = store
      else
        # Fallback (non-console / env not set): try project certs automatically
        begin
          base = defined?(Rails) ? Rails.root.join("config", "certs") : Pathname.new("config/certs")
          candidates = %w[chain.pem JPRS_DVCA_G4.pem SECOM_ROOTCA2.pem]
            .map { |f| base.join(f) }
            .select { |p| File.file?(p) && File.size?(p) }
          unless candidates.empty?
            store = OpenSSL::X509::Store.new
            store.set_default_paths
            candidates.each do |p|
              begin
                store.add_file(p.to_s)
                warn "[MeishikiFetcher][SSL] Fallback added: #{p}" if debug
              rescue OpenSSL::X509::StoreError => e
                warn "[MeishikiFetcher][SSL] Skip #{p}: #{e.class}: #{e.message}" if debug
              end
            end
            http.cert_store = store
            warn "[MeishikiFetcher][SSL] Using fallback cert store (no SSL_CA_FILE env)" if debug
          else
            warn "[MeishikiFetcher][SSL] No fallback certs found under #{base}" if debug
          end
        rescue => e
          warn "[MeishikiFetcher][SSL] Fallback setup error: #{e.class}: #{e.message}" if debug
        end
      end
    end

    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/x-www-form-urlencoded"
    req.body = form

    res = http.request(req)
    raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)
    res.body
  end

  def self.parse_html(html)
    # Nokogiriが利用可能なら使用。なければ簡易パーサで代替
    if defined?(Nokogiri)
      parse_with_nokogiri(html)
    else
      parse_with_regex(html)
    end
  end

  def self.parse_with_nokogiri(html)
    require "nokogiri"
    doc = Nokogiri::HTML.parse(html)

    # ユーティリティ
    get = ->(sel) { doc.at_css(sel)&.text&.gsub(/\u00A0|\&nbsp;|\s+/, " ")&.strip.presence }

    tenchu = doc.css(".tenchu > div").map { _1.text.strip }.reject(&:empty?)

    {
      tenchu_1: tenchu[0],
      tenchu_2: tenchu[1],
      # 干支（kanshi）
      kanshi_day_k_info_1: get.call(".kanshi .day .k_info_1"),
      kanshi_day_k_info_2: get.call(".kanshi .day .k_info_2"),
      kanshi_day_k_info_3: get.call(".kanshi .day .k_info_3"),
      kanshi_month_k_info_1: get.call(".kanshi .month .k_info_1"),
      kanshi_month_k_info_2: get.call(".kanshi .month .k_info_2"),
      kanshi_month_k_info_3: get.call(".kanshi .month .k_info_3"),
      kanshi_year_k_info_1: get.call(".kanshi .year .k_info_1"),
      kanshi_year_k_info_2: get.call(".kanshi .year .k_info_2"),
      kanshi_year_k_info_3: get.call(".kanshi .year .k_info_3"),
      # 数値ブロック
      kanshi_no_day: get.call(".kanshi_no .day3"),
      kanshi_no_month: get.call(".kanshi_no .month3"),
      kanshi_no_year: get.call(".kanshi_no .year3"),
      # 蔵干
      zokan_day: get.call(".zokan .day2"),
      zokan_month: get.call(".zokan .month2"),
      zokan_year: get.call(".zokan .year2"),
      # 通変星
      tsuhen_day: blank_to_nil(get.call(".tsuhen .day2")),
      tsuhen_month: get.call(".tsuhen .month2"),
      tsuhen_year: get.call(".tsuhen .year2"),
      # 蔵通変星
      ztsuhen_day: get.call(".ztsuhen .day2"),
      ztsuhen_month: get.call(".ztsuhen .month2"),
      ztsuhen_year: get.call(".ztsuhen .year2"),
      # 12運勢
      unsei12_day: get.call(".unsei12 .day2"),
      unsei12_month: get.call(".unsei12 .month2"),
      unsei12_year: get.call(".unsei12 .year2"),
      # エネルギー
      energy_kei: get.call(".energy .kei"),
      energy_day: get.call(".energy .day2"),
      energy_month: get.call(".energy .month2"),
      energy_year: get.call(".energy .year2")
    }
  end

  # 極力Nokogiriが使えない環境向けの簡易パース（完全一致を保証しない）
  def self.parse_with_regex(html)
    text = html.gsub(/\r|\n/, " ")
    strip_html = ->(s) { s&.gsub(/<[^>]+>/, " ")&.gsub(/\u00A0|&nbsp;|\s+/, " ")&.strip }
    # 注意: 以前ここで `def find_between ... end` のようにメソッドを定義すると
    # 実行時にトップレベル(Object)へメソッドが追加され、グローバル汚染になる。
    # 目的はローカルヘルパーなのでラムダで閉じ込める。
    find_between = ->(src, before, after) do
      if (m = src.match(/#{before}(.*?)#{after}/m))
        m[1]
      end
    end

    # かなり脆弱だが最低限の抽出を試みる
    tenchu_html = find_between.call(text, '<div class="tenchu">', '</div>')
    tenchu_vals = tenchu_html&.scan(/<div>\s*([^<]+)\s*<\/div>/)&.flatten&.map { _1.strip }
    # 同様に pick もローカル関数化
    pick = ->(src, sel) do
      # 例: sel = .zokan .day2 -> 最後のクラス(day2)を拾う
      cls = sel.split.last.delete_prefix(".")
      if (m = src.match(/<div[^>]*class=\"#{Regexp.escape(cls)}\"[^>]*>(.*?)<\/div>/))
        m[1]
      end
    end

    build = {
      tenchu_1: tenchu_vals&.[](0),
      tenchu_2: tenchu_vals&.[](1),
  kanshi_day_k_info_1: strip_html.call(pick.call(text, ".kanshi .day .k_info_1")),
  kanshi_day_k_info_2: strip_html.call(pick.call(text, ".kanshi .day .k_info_2")),
  kanshi_day_k_info_3: strip_html.call(pick.call(text, ".kanshi .day .k_info_3")),
  kanshi_month_k_info_1: strip_html.call(pick.call(text, ".kanshi .month .k_info_1")),
  kanshi_month_k_info_2: strip_html.call(pick.call(text, ".kanshi .month .k_info_2")),
  kanshi_month_k_info_3: strip_html.call(pick.call(text, ".kanshi .month .k_info_3")),
  kanshi_year_k_info_1: strip_html.call(pick.call(text, ".kanshi .year .k_info_1")),
  kanshi_year_k_info_2: strip_html.call(pick.call(text, ".kanshi .year .k_info_2")),
  kanshi_year_k_info_3: strip_html.call(pick.call(text, ".kanshi .year .k_info_3")),
  kanshi_no_day: strip_html.call(pick.call(text, ".kanshi_no .day3")),
  kanshi_no_month: strip_html.call(pick.call(text, ".kanshi_no .month3")),
  kanshi_no_year: strip_html.call(pick.call(text, ".kanshi_no .year3")),
  zokan_day: strip_html.call(pick.call(text, ".zokan .day2")),
  zokan_month: strip_html.call(pick.call(text, ".zokan .month2")),
  zokan_year: strip_html.call(pick.call(text, ".zokan .year2")),
  tsuhen_day: strip_html.call(pick.call(text, ".tsuhen .day2")),
  tsuhen_month: strip_html.call(pick.call(text, ".tsuhen .month2")),
  tsuhen_year: strip_html.call(pick.call(text, ".tsuhen .year2")),
  ztsuhen_day: strip_html.call(pick.call(text, ".ztsuhen .day2")),
  ztsuhen_month: strip_html.call(pick.call(text, ".ztsuhen .month2")),
  ztsuhen_year: strip_html.call(pick.call(text, ".ztsuhen .year2")),
  unsei12_day: strip_html.call(pick.call(text, ".unsei12 .day2")),
  unsei12_month: strip_html.call(pick.call(text, ".unsei12 .month2")),
  unsei12_year: strip_html.call(pick.call(text, ".unsei12 .year2")),
  energy_kei: strip_html.call(pick.call(text, ".energy .kei")),
  energy_day: strip_html.call(pick.call(text, ".energy .day2")),
  energy_month: strip_html.call(pick.call(text, ".energy .month2")),
  energy_year: strip_html.call(pick.call(text, ".energy .year2"))
    }

    build.transform_values { |v| v&.empty? ? nil : v }
  end

  def self.blank_to_nil(v)
    v.nil? || v.strip.empty? || v == "&nbsp;" ? nil : v
  end

  # 性別入力を外部サイトの仕様（1/2）に正規化
  def self.normalize_sex(sex)
    s = sex.to_s.strip.downcase
    return 1 if %w[1 m male man 男 男性].include?(s)
    return 2 if %w[2 f female woman 女 女性].include?(s)
    # 不明な場合は女性(2)にフォールバック（サイト仕様に合わせる）
    2
  end
end
