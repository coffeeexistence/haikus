class ApiKeysController < ApplicationController
  before_action :restrict_access, except: :create
  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      session = ApiKey.create(user_id: user.id)
      render json: session
    else
      render json: "400", status: 400
    end
  end
end

