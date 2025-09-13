class DiagnosisAiService
  def self.call(master, type:, memo:)
    # 仮実装：実際のAI APIの代わりにダミーレスポンスを返す
    generate_dummy_diagnosis(master, type, memo)
  end

  private

  def self.generate_dummy_diagnosis(master, type, memo)
    {
      "summary" => generate_summary(master, type),
      "advice" => generate_advice(master, type, memo)
    }
  end

  def self.generate_summary(master, type)
    case type
    when "恋愛運"
      "#{master.tsuhen_day}の特性を持つあなたは、情熱的で一途な恋愛をする傾向があります。#{master.energy_day}の五行エネルギーが強く、相手への思いが深くなりやすいでしょう。"
    when "仕事運"
      "#{master.tsuhen_month}の影響で、仕事では協調性を大切にするタイプです。#{master.energy_month}のエネルギーがあなたの職場での立ち位置を表しています。"
    when "金運"
      "#{master.tsuhen_year}の特性により、お金に対する価値観が形成されています。#{master.energy_year}の五行バランスが金運に影響を与えています。"
    else
      "#{master.tenchu_1}#{master.tenchu_2}の組み合わせを持つあなたは、バランス感覚に優れた性格をしています。#{master.energy_kei}のエネルギーが全体的な運勢を支配しています。"
    end
  end

  def self.generate_advice(master, type, memo)
    case type
    when "恋愛運"
      "#{memo}とのことですが、#{master.ztsuhen_day}の影響を活かして、相手の気持ちを大切にすることで良い関係が築けるでしょう。特に#{master.unsei12_day}の時期は良いタイミングです。"
    when "仕事運"
      "#{memo}という状況なら、#{master.ztsuhen_month}のエネルギーを活用することをお勧めします。#{master.unsei12_month}の運勢を味方につけて行動してみてください。"
    when "金運"
      "#{memo}については、#{master.ztsuhen_year}の特性を理解することが重要です。#{master.unsei12_year}の周期を意識した行動が金運アップにつながります。"
    else
      "#{memo}についてですが、#{master.tenchu_1}と#{master.tenchu_2}のバランスを意識することで、より良い結果が得られるでしょう。全体的に#{master.energy_kei}のエネルギーを大切にしてください。"
    end
  end
end
