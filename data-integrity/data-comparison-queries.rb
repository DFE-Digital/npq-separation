ActiveRecord::Base.connection.execute("SET statement_timeout to 0")
NPQRegistration::BaseRecord.connection.execute("SET statement_timeout to 0")

npq_ecf_ids = NPQRegistration::Application.pluck(:ecf_id)
applications_not_in_npq = NPQApplication.where.not(id: npq_ecf_ids).size
# Count of applications in ECF and not in NPQ: 79

npq_ecf_ids = NPQRegistration::Application.pluck(:ecf_id)
applications_not_in_ecf = npq_ecf_ids.size - NPQApplication.where(id: npq_ecf_ids).size
# Count of applications in NPQ and not in ECF: 703

npq_ecf_ids = NPQRegistration::LeadProvider.pluck(:ecf_id)
lp_not_in_ecf = npq_ecf_ids.size - NPQLeadProvider.where(id: npq_ecf_ids).size
# Count of lead providers in NPQ and not in ECF (by ecf_id): 0

npq_lp_names = NPQRegistration::LeadProvider.pluck(:name).map(&:downcase)
lp_not_in_ecf = npq_lp_names.size - NPQLeadProvider.where("LOWER(name) IN (?)", npq_lp_names).size
# Count of lead providers in NPQ and not in ECF (by name): 1

npq_ecf_ids = NPQRegistration::LeadProvider.pluck(:ecf_id)
lp_not_in_npq = NPQLeadProvider.where.not(id: npq_ecf_ids).size
# Count of lead providers in ECF and not in NPQ (by ecf_id): 0

npq_lp_names = NPQRegistration::LeadProvider.pluck(:name).map(&:downcase)
lp_not_in_npq = NPQLeadProvider.where.not("LOWER(name) IN (?)", npq_lp_names).size
# Count of lead providers in ECF and not in NPQ (by name): 1

npq_ecf_ids = NPQRegistration::User.pluck(:ecf_id)
users_not_in_ecf = npq_ecf_ids.size - User.where(id: npq_ecf_ids).size
# Count of users in NPQ and not in ECF (by ecf_id): 5,499

npq_emails = NPQRegistration::User.pluck(:email).map(&:downcase)
users_not_in_ecf = npq_emails.size - User.where("LOWER(email) IN (?)", npq_emails).size
# Count of users in NPQ and not in ECF (by email): 5,810

duplicate_npq_emails = (NPQRegistration::User.group('LOWER(email)').having('COUNT(LOWER(email)) > 1').count).count
# Count of users in NPQ with a duplicated email: 27

email_validator = NotifyEmailValidator.new(attributes: :email)
users_with_invalid_emails = NPQRegistration::User
  .where("email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'")
  .select do |user|
    email_validator.validate_each(user, :email, user.email)
    user.errors.include?(:email)
  end
  .size
# Count of users in NPQ with an invalid email (according to ECF validation): 11

users_with_different_emails = []
NPQRegistration::User.in_batches(of: 10_000) do |users|
  matching_users = User.where(id: users.map(&:ecf_id)).to_a.index_by(&:id)

  users.each do |user|
    matching_user = matching_users[user.ecf_id]
    next unless matching_user
    users_with_different_emails << matching_user unless matching_user.email.casecmp?(user.email)
  end
end
users_with_different_emails.size
# Count of NPQ users with the same ecf_id but different emails: 1,025

npq_ecf_ids = NPQRegistration::User.pluck(:ecf_id)
users_not_in_npq = User.where.not(id: npq_ecf_ids).size
# Count of users in ECF and not in NPQ: 165,162

NPQRegistration::User.where(get_an_identity_id_synced_to_ecf: false).size
# NPQ users where identity not synced to ECF: 11,436

matching_ecf_users_with_no_applications = []
NPQRegistration::User.in_batches(of: 10_000) do |users|
  matching_applications = NPQApplication
    .includes(participant_identity: :user)
    .joins(:participant_identity)
    .where(participant_identity: { user_id: users.map(&:ecf_id) })
    .to_a
    .index_by { |a| a.user.id }

  users.each do |user|
    matching_ecf_users_with_no_applications << user unless matching_applications.key?(user.ecf_id)
  end
end
matching_ecf_users_with_no_applications.size
# NPQ users that match to ECF users without any applications: 14,052
