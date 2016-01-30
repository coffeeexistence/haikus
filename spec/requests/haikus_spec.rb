require 'rails_helper'

describe "haikus", type: :request do

  let!(:user) { FactoryGirl.create(:user) }
  let!(:user_with_friend) { FactoryGirl.create(:user_with_friend) }

  let(:params) {{ email: user.email, password: user.password } }

  describe 'reading haikus' do
    it "should render haikus index template" do
      get '/haikus'
      expect(response).to have_http_status(200)
      expect(response).to render_template('index')
    end

    let!(:haikus) { FactoryGirl.create_list(:haiku_with_lines, 3) }
    it "should list haikus with title" do
      get '/haikus'
      expect(response.body).to include(haikus.first.lines.first.content)
      expect(assigns[:haikus]).to match_array(haikus)
    end

    context 'when logged in' do
      it "should list user's haikus with title" do
        post '/sessions', params
        user.haikus.create(FactoryGirl.attributes_for(:haiku))
        get '/haikus'
        expect(response.body).to include(user.haikus.last.lines.first.content)
      end
    end
  end

  describe 'GET /haikus/new' do
    context 'when logged in and has friends' do
      it "should render the html with emails of friends" do
        post '/sessions', { email: user_with_friend.email, password: user_with_friend.password }
        expect(response.code).to eq('302')
        get '/haikus/new'
        expect(response).to have_http_status(200)
        expect(response.body).to include(user_with_friend.friends.first.email)
        expect(response).to render_template('new')
      end
    end

    context 'when logged in and has no friends' do
      it "should render the html with no emails of friends" do
        post '/sessions', params
        expect(response.code).to eq('302')
        get '/haikus/new'
        expect(response).to have_http_status(200)
        expect(response.body).to include('No friends yet!')
        expect(response).to render_template('new')
      end
    end

    context 'when logged out' do
      it "should render the html with no emails of friends" do
        get '/haikus/new'
        expect(response).to have_http_status(200)
        expect(response.body).to include('No friends yet!')
        expect(response).to render_template('new')
      end
    end
  end

  describe 'POST /haikus' do

    context 'when logged in' do
      it "should add a new haiku with line content" do
        post '/sessions', params
        expect(response.code).to eq('302')
        expect {
          post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=>"An afternoon breeze"}}}
        }.to change(Haiku, :count).by(1)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_url)

        expect(Haiku.last.lines.first.user.email).to eq(user.email)
      end

      it "should send an invite email" do
        post '/sessions', params
        expect {
          post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=>"An afternoon breeze"}}},
                          email: "test@example.com"
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'should not add a new haiku without line content' do
        post '/sessions', params
        expect(response.code).to eq('302')
        expect {
          post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=> nil}}}
        }.to change(Haiku, :count).by(0)
        expect(response).to have_http_status(200)
      end
    end

    context 'when logged out' do
      it 'should not add a new haiku without line content' do
        expect {
          post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=>"An afternoon breeze"}}}
        }.to change(Haiku, :count).by(0)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(log_in_url)
      end

      it 'should not add a new haiku without line content' do
        expect {
          post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=> nil}}}
        }.to change(Haiku, :count).by(0)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(log_in_url)
      end
    end
  end
end
