require 'rails_helper'

describe "user", type: :request do
  let!(:new_user) { FactoryGirl.build(:user) }
  let!(:login_user) { FactoryGirl.create(:user) }
  let!(:word) { FactoryGirl.create(:word) }
  let(:existing_user) { FactoryGirl.create(:user) }
  let(:new_params) {{ user: { username: new_user.username, email: new_user.email, password: new_user.password, password_confirmation: new_user.password} } }
  let(:login_params) { {email: login_user.email, password: login_user.password} }
  let(:forgot_password_params) {{ user: {email: existing_user.email }}}
  let(:empty_forgot_password_params) {{ user: {email: '' }}}
  let(:new_password_params) {{ user: { password: existing_user.password, password_confirmation: existing_user.password }}}
  let(:invalid_email_forgot_password_params) {{ user: {email: 'wrong@g.com' }}}

  it "should render the html" do
    get '/sign_up'
    expect(response.code).to eq("200")
  end

  it "should create a user" do
    post '/users', new_params
    expect(response.code).to eq("302")
    expect(response).to redirect_to(root_path)
    e = new_params[:user][:email]
    expect(User.where(email: e).first.email).to eq(e)
  end

  it "should not create a user with error" do
    post '/users', user: { username: "", email: "", password: "", password_confirmation: ""}
    expect(response).to render_template('new')
    expect(response.body).to include("Form is invalid")
  end

  describe 'forgot password' do
    it 'navigates to the forgot password page' do
      get '/forgot_password'
      expect(response.code).to eq("200")
      expect(response).to render_template(:forgot_password)
    end

    context 'existing user' do
      before(:each) do
        patch '/enter_email', forgot_password_params
      end

      it 'saves a forgot password uuid to the user' do
        user = User.find_by(email: existing_user.email)
        expect(user.forgot_password_uuid).not_to be_nil
      end

      it 'sends a forgot password email' do
        forgot_password_email = ActionMailer::Base.deliveries.last
        recipient = forgot_password_email.to
        expect(recipient).to include(existing_user.email)
      end

      it 'renders the New Password template' do
        user = User.find_by(email: existing_user.email)
        get "/new_password/#{user.forgot_password_uuid}", new_password_params
        expect(response).to render_template(:new_password)
      end

      it "updates the user's password" do
        user = User.find_by(email: existing_user.email)
        patch "/update_password/#{user.id}", new_password_params
        expect(User.authenticate(user.email, new_password_params[:user][:password])).not_to be_nil
      end

      it 'removes the forgot password uuid after the user resets the password' do
        user = User.find_by(email: existing_user.email)
        patch "/update_password/#{user.id}", new_password_params
        expect(User.find_by(email: existing_user.email).forgot_password_uuid).to be_nil
      end      

      it 'redirects to the home page after user enters email address' do
        expect(response.code).to eq("302")
        expect(response).to redirect_to(root_path)
      end

      it 'automatically logs in user after password reset' do
        user = User.find_by(email: existing_user.email)
        patch "/update_password/#{user.id}", new_password_params
        expect(session[:user_id]).to eq(user.id)
      end
    end

    context 'left the email field blank' do
      it 'redirects to the forgot password page' do
        patch '/enter_email', empty_forgot_password_params
        expect(response.code).to redirect_to(forgot_password_path)
      end
    end

    context 'not an existing user' do
      it 'redirects to the forgot password page' do
        patch '/enter_email', invalid_email_forgot_password_params
        expect(response.code).to redirect_to(forgot_password_path)
      end
    end
  end

  describe "updates profile" do
    it "should render html of edit form" do
      get "/profile"
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Please log in before proceeding")

      post '/log_in', login_params
      get "/profile"
      expect(response).to have_http_status(200)
      expect(response).to render_template('edit')
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

    it "should not update profile without current password" do
      invalid_params = FactoryGirl.attributes_for(:user, email: "invalid@factory.com")
      put "/users/#{existing_user.id}", user: invalid_params
      expect(response.code).to eq("200")
      expect(response).to render_template :edit
      expect(existing_user.reload.email).to_not eq "invalid@factory.com"
    end
  end

  describe 'POST /add_friend' do
    it "should not be allowed without login" do
      post '/add_friend', user: {email: existing_user.email}
      expect(response).to redirect_to(log_in_url)
    end

    context 'login user' do
      before do
        post '/log_in', login_params
      end

      it "should create a two way friendship with email of existing user" do
        expect {
          post '/add_friend', user: {email: existing_user.email}
          expect(response).to have_http_status(302)
        }.to change(Friendship, :count).by(2)
        expect(login_user.reload.friends.to_a).to include(existing_user)
      end

      it "should add a user, and create a two way friendship, with a new email" do
        expect {
          post '/add_friend', user: {email: "stranger@example.com"}
        }.to change(User, :count).by(1).and change(Friendship, :count).by(2)
        expect(login_user.reload.friends.where(email: "stranger@example.com")).to exist
      end

      it "should not add another friendship, with email of a friend" do
        FactoryGirl.create(:friendship, user: login_user)
        expect {
          post '/add_friend', user: {email: login_user.friends.first.email}
        }.to raise_error.and change(Friendship, :count).by(0)
      end
    end
  end
end
