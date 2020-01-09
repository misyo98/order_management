class ProfileMailer < ActionMailer::Base
  def notify_about_to_be_fixed_profiles(user:)
    @user = user
    @profile_categories = user.created_profile_categories.to_be_fixed.uniq.group_by(&:profile)
    mail(to: @user.email, subject: 'Profile requires fixing!')
  end
end
