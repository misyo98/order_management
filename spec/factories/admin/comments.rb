FactoryBot.define do
  factory :admin_comment, class: ActiveAdmin::Comment do
    namespace { 'root' }
    body { 'CommentBody' }
    submission { false }
    author_type { 'User' }

    association :author, factory: :user
    association :category
    # association :customer
  end
end
