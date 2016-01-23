require 'rails_helper'

describe "sessions", type: :request do
  let(:user) {FactoryGirl.create(:user)}
  let(:params) {{ email: user.email, password: user.password } }

  it "should render the html" do
    get '/log_in'
    expect(response.code).to eq("200")
  end

  it "should create a session" do
    post '/sessions', params
    expect(response.code).to eq("302")
    expect(response).to redirect_to(root_path)
  end
end
