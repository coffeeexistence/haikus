require 'rails_helper'
require 'rake'

describe 'db:remove_old_uuids' do
  let!(:user) { FactoryGirl.create(:user, updated_at: "#{Time.now - 25.hours}", forgot_password_uuid:"something") }
  it "should remove old uuids if 24 hours old" do
    Rake::Task["db:remove_old_uuids"].invoke
    expect(user.reload.forgot_password_uuid).to be_nil
  end
end

