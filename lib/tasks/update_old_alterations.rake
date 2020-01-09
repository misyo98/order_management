task update_old_alterations: :environment do
  AlterationSummary.where(AlterationSummary.arel_table[:alteration_request_taken].lteq(Date.new(2018, 12, 31)))
    .update_all(state: 'paid')

  AlterationSummary.joins(:items)
    .where(LineItem.arel_table[:back_from_alteration_date].gteq(Date.new(2019, 1, 1)))
    .where(AlterationSummary.arel_table[:service_updated_at].eq(nil))
    .update_all(state: 'to_be_updated')

  AlterationSummary.joins(:items)
    .where(AlterationSummary.arel_table[:alteration_request_taken].gteq(Date.new(2019, 1, 1)))
    .where(LineItem.arel_table[:back_from_alteration_date].eq(nil))
    .update_all(state: 'to_be_altered')
  
  AlterationSummary.joins(:items)
    .where(LineItem.arel_table[:back_from_alteration_date].not_eq(nil))
    .where(state: nil)
    .update_all(state: 'to_be_updated')
    
  AlterationSummary.where(state: nil).update_all(state: 'to_be_altered')

  puts 'Updated old alterations'
end
