require 'rails_helper'

RSpec.describe InvoiceAlterationSummary, type: :model do
  it { is_expected.to belong_to :invoice }
  it { is_expected.to belong_to :alteration_summary }
end
