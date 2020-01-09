task set_auth_tokens: :environment do
  User.all.each { |user| user.set_auth_token; user.save }
end
