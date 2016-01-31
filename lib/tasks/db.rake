require 'rake'

namespace :db do
  task :remove_old_uuids => :environment do
    users = User.where.not(forgot_password_uuid:nil)
    users.each do |user|
      if user.updated_at < Time.now - 24.hours
        user.update_attribute(:forgot_password_uuid, nil)
      end
    end
  end
end
