require "yaml"

namespace :yorimichi_bingo do
  desc "Import categories and items from db/templates"
  task import_templates: :environment do
    TemplateImporter.new.call
  end

  class TemplateImporter
    def call
      categories_data = load_yaml("yorimichi_bingo_categories.yml")
      items_data = load_yaml("yorimichi_bingo_items.yml")

      ActiveRecord::Base.transaction do
        categories = import_categories(categories_data)
        import_items(items_data, categories)
      end

      puts "Imported #{Features::YorimichiBingo::BingoCategory.count} categories and #{Features::YorimichiBingo::BingoItem.count} items."
    end

    private

    def load_yaml(filename)
      path = Rails.root.join("db", "templates", filename)
      raise "テンプレートファイルが見つかりません: #{path}" unless File.exist?(path)

      YAML.safe_load_file(path, aliases: true)
    end

    def import_categories(data)
      data.each_with_object({}) do |attrs, memo|
        category = Features::YorimichiBingo::BingoCategory.find_or_initialize_by(slug: attrs.fetch("slug"))
        category.update!(display_name: attrs.fetch("display_name"), description: attrs["description"])
        memo[category.slug] = category
      end
    end

    def import_items(data, categories)
      data.each do |attrs|
        slug = attrs.fetch("category_slug")
        category = categories[slug]
        raise "カテゴリが見つかりません: #{slug}" unless category

        item = Features::YorimichiBingo::BingoItem.find_or_initialize_by(
          bingo_category: category,
          title: attrs.fetch("title")
        )
        item.update!(
          description: attrs["description"],
          illustration: attrs["illustration"],
          active: attrs.fetch("active", true)
        )
      end
    end
  end
end
