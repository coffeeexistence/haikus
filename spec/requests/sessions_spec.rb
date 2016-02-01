require 'rails_helper'

describe "sessions", type: :request do
  let(:user) {FactoryGirl.create(:user)}
  let(:params) {{ email: user.email, password: user.password } }

  it "should render the html" do
    get '/log_in'
    expect(response.code).to eq("200")
  end

  it "should create a session" do
    post '/log_in', params
    expect(response.code).to eq("302")
    expect(response).to redirect_to(root_path)
    expect(session[:user_id]).to_not be_nil
  end

  it "should give an error if not authenticated" do
    post '/log_in', {email: '', password: ''}
    expect(response).to render_template('new')
    expect(response.body).to include("Invalid email or password")
  end

  it 'should destroy a session' do
    get '/log_out'
    expect(response).to redirect_to(root_path)
    expect(session[:user_id]).to be_nil
  end
end
