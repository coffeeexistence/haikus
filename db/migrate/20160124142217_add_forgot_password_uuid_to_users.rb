class AddForgotPasswordUuidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :forgot_password_uuid, :string
  end
end
