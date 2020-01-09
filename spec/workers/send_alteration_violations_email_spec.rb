# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendAlterationViolationsEmail, type: :job do
  let(:profile) { create :profile }
  let(:customer) { create :customer, profile: profile, first_name: 'Jack', last_name: 'Dosson', email: 'customer@gmail.com' }
  let(:submitter) { create :user, first_name: 'Admin', last_name: 'User' }
  let(:user) { create :user, first_name: 'John', last_name: 'Snow', email: 'user@gmail.com' }
  let(:user2) { create :user, first_name: 'Jack', last_name: 'Show', email: 'user2@gmail.com' }
  let(:selected_users) { [user.id, user2.id] }
  let(:violation) { { 'Chest allowance seems too large': 'Jacket - Chest' }.to_json }
  let(:mail) { AlterationMailer.after_alteration_violations(customer: customer, submitter: submitter, user: user, violations: violation).deliver_now }

  describe 'send_alteration_email_to_staff' do
    context 'with billing country' do
      it 'sends an email' do
        expect { described_class.perform_async(customer.id, user.id, violation, selected_users) }.to change { Sidekiq::Worker.jobs.size }.by 1
      end

      it 'renders the headers' do
        expect(mail.subject).to eq 'Alteration Validation Violations - Alteration submitted to Jack Dosson by Admin User'
        expect(mail.to).to eq ['user@gmail.com']
        expect(mail.from).to eq ['noreply@example.com']
      end

      it 'renders the body' do
        expect(mail.body.encoded).to match 'just submitted an alteration for'
        expect(mail.body.encoded).to match 'The following requested alterations are not respecting the listed validation rules'
        expect(mail.body.encoded).to match 'customer@gmail.com'
        expect(mail.body.encoded).to match 'John Snow'
      end
    end

    context 'without billing country' do
      let(:mail2) { AlterationMailer.after_alteration_violations(customer: customer, submitter: submitter, user: user, violations: violation).deliver_now }

      it 'sends an email to default' do
        expect(mail2.to).to eq ['user@gmail.com']
      end
    end
  end
end
