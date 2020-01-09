# frozen_string_literal: true

module Importers
  class Objects::FabricInfos < Importers::Base
    FABRIC_INFOS_ATTRIBUTES = {
      order:                    'Order',
      fabric_brand_id:          'Fabric Brand',
      fabric_book_id:           'Fabric Book',
      fabric_code:              'Fabric Code',
      manufacturer_fabric_code: 'RC Fabric Code',
      fabric_composition:       'Fabric Composition',
      fabric_tier_id:           'Fabric Tier Id',
      fabric_type:              'Cut-Length?',
      manufacturer:             'Manufacturer',
      fusible:                  'Fusible',
      premium:                  'Premium',
      season:                   'Season',
      active:                   'Active',
      usd_for_meter:            'USD / m',
      fabric_addition:          'Fabric addition (USD) / m',
      valid_from:               'Valid From'
    }.freeze

    CATEGORIES = {
      shirts:                   'Shirts',
      trousers:                 'Trousers',
      jackets:                  'Jackets',
      waistcoats:               'Waistcoats',
      overcoats:                'Overcoats',
      chinos:                   'Chinos',
      trench_coats:             'TrenchCoats'
    }.freeze

    CUT_LENGTH = {
      'yes' => 'cut_length',
      'no' => 'stock'
    }.freeze

    ALLOWED_MANUFACTURERS = %w(blank_m old_m new_m).freeze

    def initialize(tempfile_path:)
      @old_fabric_codes        = FabricInfo.pluck(:fabric_code)
      @old_fabric_books        = FabricBook.pluck(:title)
      @old_fabric_brands       = FabricBrand.pluck(:title)
      @new_fabric_codes        = []
      @new_fabric_books        = []
      @new_fabric_brands       = []
      @fabric_categories       = FabricCategory.all.each_with_object({}) { |category, hash| hash[category.title] = category.id }
      @tempfile_path           = tempfile_path
      @rows_count              = CSV.readlines(tempfile_path).uniq.delete_if { |item| item.all? { |k| k.nil? } }.size - 1 #ignoring headers row and empty row for some encodings
      @fabrics_updated         = []
      @archived_count          = 0
      @new_fabrics_added_count = 0
      @fabrics_unchanged_count = 0
      @row_index               = 0
      @updated_progress        = 0
      @duplicate_fabrics       = 0
    end

    private

    attr_reader :old_fabric_codes, :old_fabric_books, :old_fabric_brands, :new_fabric_codes, :new_fabric_books, :new_fabric_brands,
                  :fabric_categories, :tempfile_path, :rows_count, :row_index, :updated_progress, :new_fabrics_added_count,
                  :fabrics_updated, :fabrics_unchanged_count, :archived_count, :duplicate_fabrics

    def process
      CSV.foreach(tempfile_path, headers: true, quote_char: "\"", row_sep: :auto, col_sep: ',') do |row|
        attributes = scrape_attributes(line: row.to_hash, attributes_hash: FABRIC_INFOS_ATTRIBUTES)

        @duplicate_fabrics += 1 if attributes[:fabric_code].in?(new_fabric_codes)

        next if attributes[:fabric_code].blank? || attributes[:fabric_code].in?(new_fabric_codes)

        categories = scrape_attributes(line: row.to_hash, attributes_hash: CATEGORIES)
        formatted_attributes = format_fabric_attributes(attributes)

        fabric_info = resolve_fabric_info(formatted_attributes)

        fabric_info.save

        assign_enabled_categories(fabric_info, categories)

        @new_fabric_codes << fabric_info.fabric_code
        progress_result
      end

      archive_unused
      pusher_success_import

      result(success: true, count: rows_count)
    end

    def format_fabric_attributes(attributes)
      fabric_type         = attributes[:fabric_type]&.underscore
      fabric_manufacturer = attributes[:manufacturer]&.underscore
      fabric_book         = FabricBook.unscoped.find_or_create_by(title: attributes[:fabric_book_id])
      fabric_brand        = FabricBrand.unscoped.find_or_create_by(title: attributes[:fabric_brand_id])

      fabric_book.update(deleted_at: nil) if fabric_book
      fabric_brand.update(deleted_at: nil) if fabric_brand

      @new_fabric_books << fabric_book.title
      @new_fabric_brands << fabric_brand.title

      attributes[:fabric_book_id]  = fabric_book.id
      attributes[:fabric_brand_id] = fabric_brand.id
      attributes[:fabric_type]     = CUT_LENGTH[fabric_type]
      attributes[:manufacturer]    = fabric_manufacturer.in?(ALLOWED_MANUFACTURERS) ? fabric_manufacturer : nil
      attributes[:fusible]         = to_true_or_false(attributes[:fusible])
      attributes[:premium]         = to_true_or_false(attributes[:premium])
      attributes[:active]          = to_true_or_false(attributes[:active])
      attributes[:deleted_at]      = nil
      attributes[:usd_for_meter]   = attributes[:usd_for_meter]&.to_f&.round(2)

      attributes
    end

    def assign_enabled_categories(fabric_info, categories)
      categories.each do |key, value|
        if to_true_or_false(value)
          fabric_info.enabled_fabric_categories.find_or_create_by(fabric_category_id: fabric_categories[key.to_s.camelize])
        else
          fabric_info.enabled_fabric_categories&.find_by(fabric_category_id: fabric_categories[key.to_s.camelize])&.destroy
        end
      end
    end

    def to_true_or_false(param)
      return false unless param

      param.strip.downcase == 'yes' ? true : false
    end

    def resolve_fabric_info(formatted_attributes)
      fabric_info = FabricInfo.unscoped.where(fabric_code: formatted_attributes[:fabric_code]).last

      if fabric_info
        fabric_info.assign_attributes(formatted_attributes)

        if fabric_info.valid_from_changed? || fabric_info.usd_for_meter_changed?
          fabric_info.destroy

          @fabrics_updated << fabric_info.fabric_code

          fabric_info = FabricInfo.new(formatted_attributes)
        elsif fabric_info.changed?
          @fabrics_updated << fabric_info.fabric_code
        else
          @fabrics_unchanged_count += 1
        end

        fabric_info
      else
        @new_fabrics_added_count += 1
        fabric_info = FabricInfo.new(formatted_attributes)
      end

      fabric_info
    end

    def archive_unused
      unused_books  = old_fabric_books - new_fabric_books
      unused_brands = old_fabric_brands - new_fabric_brands
      unused_codes  = old_fabric_codes - new_fabric_codes

      FabricBook.unscoped.where(title: unused_books).update_all(deleted_at: DateTime.current) if unused_books.any?
      FabricBrand.unscoped.where(title: unused_brands).update_all(deleted_at: DateTime.current) if unused_brands.any?
      FabricInfo.unscoped.where(fabric_code: unused_codes).update_all(deleted_at: DateTime.current) if unused_codes.any?

      @archived_count = (old_fabric_codes.count - FabricInfo.count).abs if unused_codes.any?
    end

    def pusher_success_import
      Pusher.trigger('fabric-infos-import-channel', 'fabric-infos-imported-event', {
        message: "Successfully processed #{rows_count} rows, which results for Fabric Infos: #{new_fabrics_added_count} added,
                  #{fabrics_updated.count} updated, #{fabrics_unchanged_count} unchanged,
                  #{archived_count} archived and #{duplicate_fabrics} rows were ignored due to duplication."
      })
    end

    def current_progress_percentage(row_index)
      ((row_index.to_f / rows_count.to_f) * 100).round(0)
    end

    def progress_result
      @row_index += 1
      current_progress = current_progress_percentage(row_index)

      if current_progress > updated_progress
        Thread.new do
          begin
            @updated_progress = current_progress
            Pusher.trigger('fabric-infos-import-progress-channel', 'fabric-infos-import-progress-event', {
              progress: updated_progress
            })
          rescue Pusher::Error => error
            puts "#{DateTime.current}: Pusher error - #{error.message}"
          end
        end
      end
    end
  end
end
