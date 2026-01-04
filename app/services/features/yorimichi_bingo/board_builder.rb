module Features
  module YorimichiBingo
    class BoardBuilder
      DEFAULT_TITLE = "いつもとちがう30日".freeze
      DEFAULT_DURATION_DAYS = 30
      MAX_ITEMS = 25

      class CategorySelectionError < StandardError; end

      class << self
        def items_for_category_slugs(category_slugs)
          slugs = normalize_slugs(category_slugs)
          validate_slug_count!(slugs)

          categories = BingoCategory.where(slug: slugs)
          missing = slugs - categories.map(&:slug)
          raise CategorySelectionError, "存在しないカテゴリが含まれています。" if missing.any?

          pool = BingoItem.active.where(bingo_category: categories).includes(:bingo_category).to_a
          raise CategorySelectionError, "選択したカテゴリの候補マスが25件に満たないため作成できません。" if pool.size < MAX_ITEMS

          selected_items = pick_items(pool, categories)
          selected_items.map.with_index(1) { |item, index| payload_for(item, index) }
        end

        private

        def normalize_slugs(slugs)
          Array(slugs).map { |slug| slug.to_s.strip }.reject(&:blank?).uniq
        end

        def validate_slug_count!(slugs)
          if slugs.length < 3 || slugs.length > 8
            raise CategorySelectionError, "カテゴリは3〜8個選んでください。"
          end
        end

        def pick_items(pool, categories)
          grouped = categories.index_by(&:slug).transform_values { [] }
          pool.shuffle.each do |item|
            slug = item.category_slug
            grouped[slug] ||= []
            grouped[slug] << item
          end

          selection = ensure_each_category_has_one(grouped)
          remaining = grouped.values.flatten.compact.shuffle
          selection += remaining
          selection.compact.first(MAX_ITEMS)
        end

        def ensure_each_category_has_one(grouped)
          grouped.each_with_object([]) do |(_slug, items), memo|
            memo << items.shift if items.present?
          end
        end

        def payload_for(item, index)
          {
            "id" => index,
            "title" => item.title,
            "description" => item.description,
            "category_slug" => item.category_slug,
            "checked" => false,
            "checked_at" => nil,
            "illustration" => item.illustration
          }.compact
        end
      end

      DEFAULT_ITEMS = [
        "いつもと違う道で帰る",
        "新しいパン屋さんに寄る",
        "図書館で雑誌を一冊めくる",
        "公園で深呼吸を3回する",
        "夜空の星を5つ探す",
        "知らない国の料理を食べる",
        "道端の花の名前を調べる",
        "手紙を書いてみる",
        "朝にラジオ体操する",
        "本屋で表紙買いする",
        "誰かに「ありがとう」を伝える",
        "水筒に好きな飲み物を入れる",
        "ポッドキャストを新しく聞く",
        "知らない音楽ジャンルを聴く",
        "おにぎりを握って外で食べる",
        "昔の写真を1枚見返す",
        "初めてのスーパーに寄る",
        "近くの神社にお参りする",
        "早起きして朝日を見る",
        "寝る前にストレッチする",
        "新しい香りのものを試す",
        "メモを1ページ自由に描く",
        "誰かに小さなおすそ分けをする",
        "水辺を10分眺める",
        "今日よかったことを3つ書く"
      ].freeze

      def initialize(title:, duration_days: DEFAULT_DURATION_DAYS)
        @title = title.presence || DEFAULT_TITLE
        @duration_days = normalize_duration(duration_days)
      end

      def call
        BingoCard.create!(
          title: @title,
          items: build_items,
          expires_at: @duration_days.days.from_now
        )
      end

      private

      def build_items
        DEFAULT_ITEMS.first(MAX_ITEMS).map.with_index(1) do |item_title, index|
          {
            "id" => index,
            "title" => item_title,
            "checked" => false,
            "checked_at" => nil
          }
        end
      end

      def normalize_duration(duration_days)
        days = duration_days.to_i
        return DEFAULT_DURATION_DAYS if days <= 0

        days
      end
    end
  end
end
