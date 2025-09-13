module IconHelper
  # 通変星 → 画像ファイル名の対応（仮マッピング）
  # 必要に応じて t_*.svg の対応を調整してください。
  # 指定: t_1 から順に
  # 劫財、比肩、印綬、偏印、傷官、食神、正財、偏財、正官、偏官
  TSUHEN_MAP = {
    "劫財" => "t_1.svg",
    "比肩" => "t_2.svg",
    "印綬" => "t_3.svg",
    "偏印" => "t_4.svg",
    "傷官" => "t_5.svg",
    "食神" => "t_6.svg",
    "正財" => "t_7.svg",
    "偏財" => "t_8.svg",
    "正官" => "t_9.svg",
    "偏官" => "t_10.svg"
  }.freeze

  # 12運勢 → 画像ファイル名の対応（一般的な順序で仮設定）
  # 指定: u_1 から順に
  # 胎、養、長生、沐浴、冠帯、建禄、帝旺、衰、病、死、墓、絶
  UNSEI_MAP = {
    "胎"   => "u_1.svg",
    "養"   => "u_2.svg",
    "長生" => "u_3.svg",
    "沐浴" => "u_4.svg",
    "冠帯" => "u_5.svg",
    "建禄" => "u_6.svg",
    "帝旺" => "u_7.svg",
    "衰"   => "u_8.svg",
    "病"   => "u_9.svg",
    "死"   => "u_10.svg",
    "墓"   => "u_11.svg",
    "絶"   => "u_12.svg"
  }.freeze

  # パス解決（文字列 → assets パス）
  def tsuhen_icon_path(term)
    key = term.to_s.strip
    file = TSUHEN_MAP[key]
    file ? asset_path("tsuhen/#{file}") : nil
  end

  def unsei_icon_path(term)
    key = term.to_s.strip
    file = UNSEI_MAP[key]
    file ? asset_path("unsei/#{file}") : nil
  end

  # image_tag を返す（見つからなければ nil）
  def tsuhen_icon_tag(term, **options)
    path = tsuhen_icon_path(term)
    return nil unless path
    defaults = { alt: term, class: "inline-block h-6 w-6 align-text-bottom" }
    image_tag(path, **defaults.merge(options))
  end

  def unsei_icon_tag(term, **options)
    path = unsei_icon_path(term)
    return nil unless path
    defaults = { alt: term, class: "inline-block h-6 w-6 align-text-bottom" }
    image_tag(path, **defaults.merge(options))
  end

  # 汎用：通変星→12運勢の順に探す（見つからなければテキストをそのまま返すオプション）
  def meishiki_icon_tag(term, fallback_text: false, **options)
    tsuhen_icon_tag(term, **options) ||
      unsei_icon_tag(term, **options) ||
      (fallback_text ? content_tag(:span, term.to_s, class: options[:class]) : nil)
  end
end
