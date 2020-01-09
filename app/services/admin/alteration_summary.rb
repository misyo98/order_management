module Admin
  class AlterationSummary

    DEFAULT_DATE = Date.today
    ALTERATION_INFO = %w(lapel_flaring shoulder_fix move_button square_back_neck armhole).freeze

    def initialize(user_id: 0, start: DEFAULT_DATE, end_date: DEFAULT_DATE, category_ids: [])
      end_date = end_date.to_date.end_of_day
      @measurements   = Measurement.for_alterations(
        id:       user_id,
        start:    start,
        end_date: end_date
      )
      @raw_submissions = Measurement.uniq_submitted_categories(
        id:       user_id,
        start:    start,
        end_date: end_date
      )
      @alteration_infos = AlterationInfo.for_summaries(
        author_id:  user_id,
        start_date: start.to_date.beginning_of_day,
        end_date:   end_date
      )
      @category_submissions = count_submissions
      @category_profiles    = form_submitted_profiles
      @category_ids         = category_ids
      @summaries            = form_summaries
    end

    def summary_info
      form_alteration_infos
      scrape_summary_info
      summaries
    end

    private

    attr_reader   :measurements, :category_submissions, :category_ids, :raw_submissions, :category_profiles, :alteration_infos
    attr_accessor :summaries

    def count_submissions
      raw_submissions.inject(Hash.new(0)) { |hash, data_array| hash[data_array.last] += 1; hash }
    end

    def form_submitted_profiles
      response_hash = {}
      raw_submissions.each do |array|
        if response_hash[array.last]
          response_hash[array.last] << array.first
        else
          response_hash[array.last] = [array.first]
        end
      end
      response_hash
    end

    def form_summaries
      category_params = category_ids.empty? ? CategoryParam.all_for_alterations : CategoryParam.specific_for_alterations(category_ids)
      summaries = category_params.inject([]) do |array, obj|
        array << Admin::Summary.new(id:          obj.id,
                                    category:    obj.category_name,
                                    param:       obj.param_title,
                                    category_id: obj.category_id)
        array
      end
    end

    def form_alteration_infos
      jacket = Category.jacket
      return unless jacket
      ind = summaries.each_index.select{ |i| summaries[i].category_param[:category_id] == jacket.id }.last || summaries.length
      ALTERATION_INFO.each do |info|
        selected = alteration_infos.select{ |i| i.send(info).present? }
        summary = Admin::Summary.new(
          category:    jacket.name,
          param:       info.humanize,
          category_id: jacket.id)
        summary.alter_total = selected.size
        summary.alter_total_ids = selected.select(&:profile_id).inject([]) { |hash, info| hash << info.profile_id }
        ind += 1
        summaries.insert(ind, summary)
      end

    end

    def scrape_summary_info
      measurements.each do |measurement|
        next unless summary = find_summary(measurement.category_param_id)

        calculate_adjustment(measurement: measurement, summary: summary)
        calculate_alterations(measurement: measurement, summary: summary)
      end
      calculate_totals
    end

    def find_summary(id)
      summaries.detect { |summary| summary.category_param[:id] == id }
    end

    def calculate_adjustment(measurement:, summary:)
      return if measurement.adjustment == 0

      if measurement.adjustment && measurement.adjustment > 0
        summary.adjustment_increase += 1
        summary.adjustment_increase_ids << measurement.profile_id
      elsif measurement.adjustment && measurement.adjustment < 0
        summary.adjustment_decrease += 1
        summary.adjustment_decrease_ids << measurement.profile_id
      end
    end

    def calculate_alterations(measurement:, summary:)
      size = measurement.alterations.size
      return if size == 0

      measurement.alterations.each do |alter|
        if alter.value && alter.value > 0
          summary.alter_increase += 1
          summary.alter_increase_ids << measurement.profile_id
        elsif alter.value && alter.value < 0
          summary.alter_decrease += 1
          summary.alter_decrease_ids << measurement.profile_id
        end
      end
    end

    def calculate_totals
      summaries.compact.each do |summary|
        calculate_alter_total(summary: summary)
        calculate_alter_total_ids(summary: summary)
        calculate_total_submissions(summary: summary)
        calculate_total_submissions_ids(summary: summary)
        calculate_alter_percentage(summary: summary)
      end
    end

    def calculate_alter_total(summary:)
      summary.alter_total += (summary.alter_increase + summary.alter_decrease)
      # summary.alter_total += (summary.adjustment_increase + summary.adjustment_decrease)
    end

    def calculate_alter_total_ids(summary:)
      unless summary.category_param[:param].in?(ALTERATION_INFO.map(&:humanize))
        summary.alter_total_ids = (
          summary.alter_increase_ids +
          summary.alter_decrease_ids +
          summary.adjustment_increase_ids +
          summary.adjustment_decrease_ids
        )
      end
    end

    def calculate_total_submissions(summary:)
      return unless category_submissions[summary[:category_param][:category_id]]
      summary.total_submissions = category_submissions[summary[:category_param][:category_id]]
    end

    def calculate_total_submissions_ids(summary:)
      return unless category_profiles[summary[:category_param][:category_id]]
      summary.total_submissions_ids = category_profiles[summary[:category_param][:category_id]]
    end

    def calculate_alter_percentage(summary:)
      summary.alter_percentage = percentage(alterations: summary.alter_total, submissions: summary.total_submissions)
    end

    def percentage(alterations:, submissions:)
      return 0.0 if alterations == 0 && submissions == 0
      (alterations.to_f / submissions.to_f * 100).round(2)
    end
  end
end

# Summary Struct:
# category_param,
# adjustment_increase,
# adjustment_increase_ids,
# adjustment_decrease,
# adjustment_decrease_ids,
# alter_increase,
# alter_increase_ids,
# alter_decrease,
# alter_decrease_ids,
# alter_total,
# alter_total_ids,
# total_submissions,
# total_submissions_ids,
# alter_percentage
