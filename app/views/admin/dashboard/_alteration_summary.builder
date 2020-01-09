context.instance_eval  do
  render 'admin/customer/checkboxes', checked: true, categories: Category.visible.pluck(:name, :id), custom_class: 'alteration-categories'
  panel "Alteration Summary" do
    table_for summaries, class: 'table table-bordered table-hover' do |summary|
      column("Category")                 { |summary| summary.category_param[:category] }
      column("Measurement")              { |summary| summary.category_param[:param] }
      column('Adjustment Increase')      { |summary| summary.adjustment_increase == 0 ? nil : (span link_to(summary.adjustment_increase, customers_path(q: { profile_id_includes: summary.adjustment_increase_ids.uniq.push(0).join(',') }, commit: :filter))) }
      column('Adjustment Decrease')      { |summary| summary.adjustment_decrease == 0 ? nil : (span link_to(summary.adjustment_decrease, customers_path(q: { profile_id_includes: summary.adjustment_decrease_ids.uniq.push(0).join(',') }, commit: :filter))) }
      column('Alterations Increase')     { |summary| summary.alter_increase == 0 ? nil : (span link_to(summary.alter_increase, customers_path(q: { profile_id_includes: summary.alter_increase_ids.uniq.push(0).join(',') }, commit: :filter))) }
      column('Alterations Decrease')     { |summary| summary.alter_decrease == 0 ? nil : (span link_to(summary.alter_decrease, customers_path(q: { profile_id_includes: summary.alter_decrease_ids.uniq.push(0).join(',') }, commit: :filter))) }
      column('Alterations Total')        { |summary| summary.alter_total == 0 ? nil : (span link_to(summary.alter_total, customers_path(q: { profile_id_includes: summary.alter_total_ids.uniq.push(0).join(',') }, commit: :filter))) }
      column('Total Meas. Submissions')  { |summary| summary.total_submissions == 0 ? nil : (span link_to(summary.total_submissions, customers_path(q: { profile_id_includes: summary.total_submissions_ids.uniq.push(0).join(',') }, commit: :filter)), class: 'total-submissions') }
      column("% Altered")                { |summary| summary.alter_percentage }
    end
  end
end
