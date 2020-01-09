module Exporters
  module Objects
    class Issues < Exporters::Base
      private

      def process
        fast_fields_xls
      end

      def fast_fields_xls
        CSV.generate(headers: true) do |csv|
          csv << [
            'CUSTOMER ID',
            'CUSTOMER NAME',
            'CREATED AT',
            'OUTFITTER',
            'CATEGORY NAME',
            'MEASUREMENT',
            'ISSUE',
            'FIXED?',
            'TIME TO BE FIXED',
            'COMMENTS'
          ]

          records.each do |record|
            r = MeasurementIssueDecorator.decorate(record)
            csv << [
              r.customer_id,
              r.customer_name,
              r.created_at,
              r.outfitter,
              r.category_name,
              r.measurement_name,
              r.issue_subject.title,
              r.fixed?,
              r.time_to_be_fixed,
              r.messages.pluck(:body).join('; ')
            ]
          end
        end
      end
    end
  end
end
