require 'rails_helper'

describe "user", type: :request do
  let!(:user) { FactoryGirl.build(:user) }
  let(:existing_user) { FactoryGirl.create(:user) }
  let(:params) {{ user: { email: user.email, password: user.password, password_confirmation: user.password} } }
  let(:forgot_password_params) {{ user: {email: existing_user.email }}}
  let(:invalid_email_forgot_password_params) {{ user: {email: 'wrong@g.com' }}}

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

  describe 'forgot password' do
    it 'navigates to the forgot password page' do
      get '/forgot_password'
      expect(response.code ).to eq("200")
      expect(response).to render_template(:forgot_password)
    end

    context 'existing user' do
      it 'saves a forgot password uuid to the user' do
        patch '/enter_email', forgot_password_params
        expect(User.find_by(email: existing_user.email).forgot_password_uuid).not_to be_nil
      end

      it 'redirects to the home page after user enters email address' do
        patch '/enter_email', forgot_password_params
        expect(response.code).to eq("302")
        expect(response).to redirect_to(root_path)
      end
    end

    context 'not an existing user' do
      it 'redirects to the forgot password page' do
        patch '/enter_email', invalid_email_forgot_password_params
        expect(response.code).to redirect_to(forgot_password_path)
      end
    end
  end

  it "should update user profile" do
    updated_params = FactoryGirl.attributes_for(:user,
      email: "update@factory.com",
      current_password: existing_user.password
    )
    put "/users/#{existing_user.id}", user: updated_params
    expect(response.code).to eq("302")
    expect(response).to redirect_to root_path
    expect(existing_user.reload.email).to eq "update@factory.com"
  end
end
