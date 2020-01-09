# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActiveAdmin::Comment, type: :model do
  let(:customer) { create :customer }
  let(:author) { create :user, first_name: 'Existing' }
  let(:admin_comment) { create :admin_comment, author: author, resource_id: customer.id, resource_type: 'Customer' }

  context 'existing author' do
    it { expect(admin_comment.author.first_name).to eq 'Existing' }
  end

  context 'deleted user' do
    let(:author) { create :user, first_name: 'Deleted' , deleted_at: Date.today }

    it { expect(admin_comment.author.first_name).to eq 'Deleted' }
  end
end
