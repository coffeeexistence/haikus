require 'rails_helper'

describe "user", type: :request do
  let!(:user) { FactoryGirl.build(:user) }
  let(:params) {{ user: { email: user.email, password: user.password, password_confirmation: user.password} } }

  it "should render the html" do
    get '/sign_up'
    expect(response.code).to eq("200")
  end

  it "should create a user" do
    post '/users', params
    expect(response.code).to eq("302")
    expect(response).to redirect_to(root_path)
    e = params[:user][:email]
    expect(User.where(email: e).first.email).to eq(e)
  end
end
