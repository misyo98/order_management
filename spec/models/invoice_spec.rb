require 'rails_helper'

RSpec.describe Invoice, type: :model do
  it { is_expected.to belong_to :alteration_tailor }
  it { is_expected.to have_many(:files).class_name 'InvoiceFile' }
  it { is_expected.to have_many :invoice_alteration_summaries }
  it { is_expected.to have_many(:alteration_summaries).through :invoice_alteration_summaries }
  it { is_expected.to define_enum_for(:status).with %i(invoiced paid) }
end
