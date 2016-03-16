require 'rails_helper'

describe "haikus", type: :request do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:user_with_friend) { FactoryGirl.create(:user_with_friend) }
  let!(:word) { FactoryGirl.create(:word) }
  let(:params) {{ email: user.email, password: user.password } }
  let(:update_params) {{ haiku: {"lines_attributes"=>{"0"=>{"content"=>"updated first line", "id"=>"1"}, "1"=>{"content"=>"updated second line", "id"=>"2"}, "2"=>{"content"=>"updated third line", "id"=>"3"}}} }}
  let(:update_params_with_same_user_id) {{ haiku: {"lines_attributes"=>{"0"=>{"content"=>"same first same", "id"=>"1", "user_id" => "9"}, "1"=>{"content"=>"same second same", "id"=>"2", "user_id" => "9"}, "2"=>{"content"=>"same third same", "id"=>"3", "user_id" => "9"}}} }}

  describe 'reading haikus' do
    it "should render haikus index template" do
      get '/haikus'
      expect(response).to have_http_status(200)
      expect(response).to render_template('index')
    end

    let!(:haikus) { FactoryGirl.create_list(:haiku_with_lines, 3) }
    it "should list all completed haikus with title" do
      get '/haikus'
      expect(response.body).to include(haikus.first.lines.first.content)
      expect(assigns[:haikus]).to match_array(haikus)
    end

    context 'when logged in' do
      before(:each) do
        post '/log_in', params
        post '/haikus', haiku: {"lines_attributes"=>{"1"=>{"content"=> "2"}}}
        post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=> "4"}}}
        user.haikus.last.update(lines_attributes:[{user: user, content:"second line"}, {user: user, content:"third line"}])
      end

      it "should list user's haikus with title" do
        get '/haikus' 
        expect(response.body).to include(user.haikus.last.lines.first.content)
      end

      it "display an complete link and in progress link" do
        get '/haikus'
        expect(response.body).to include("Complete")
        expect(response.body).to include("In progress")
      end

      it "should display only complete haikus when the complete link is clicked, complete can not be clicked now" do
        get '/haikus', {:scope_param => 'complete'}
        expect(response.body).not_to include("Complete")
        expect(response.body).to include("All")
        expect(Haiku.complete).to include(user.haikus.last)
        expect(Haiku.complete).not_to include(user.haikus.first)
      end

      it "should display only haikus in progress when the in progress link is clicked, in progress can not be clicked now" do
        get '/haikus', {:scope_param => 'in_progress'}
        expect(response.body).to include("All")
        expect(response.body).not_to include("In progress")
        expect(Haiku.in_progress).to include(user.haikus.first)
        expect(Haiku.in_progress).not_to include(user.haikus.last)
      end
    end
  end

  describe 'GET /haikus/new' do
    context 'when logged in and has friends' do
      it "should render the html with emails of friends" do
        post '/log_in', { email: user_with_friend.email, password: user_with_friend.password }
        expect(response.code).to eq('302')
        get '/haikus/new'
        expect(response).to have_http_status(200)
        expect(response.body).to include(user_with_friend.friends.first.email)
        expect(response).to render_template('new')
      end
    end

    context 'when logged in and has no friends' do
      it "should render the html with no emails of friends" do
        post '/log_in', params
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
      before do
        post '/log_in', params
        expect(response).to have_http_status(302)
      end

      it "should add a new haiku with line content" do
        expect {
          post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=>"An afternoon breeze"}}}
        }.to change(Haiku, :count).by(1)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_haiku_line_path(Haiku.last))

        expect(Haiku.last.lines.first.user.email).to eq(user.email)
      end

      it "should send an invite email" do
        expect {
          post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=>"An afternoon breeze"}}},
                          email: "test@example.com"
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'should not add a new haiku without line content' do
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

    context 'when inviting a friend to write a haiku' do
      before do
        post '/log_in', params
      end

      it 'should have a username if friend is already a user' do
        post '/add_friend', user: { email: user.email }
        expect(user.reload.friends.last.username).to eq(user.username)
      end

      it 'should generate a random username if friend is not already a user' do
        expect(User.all.where(email: "friend@example.com")).to_not exist
        post '/add_friend', user: { email: "friend@email.com" }
        expect(user.reload.friends.last.username).to eq(word.word)
      end
    end

    context 'when invited friend clicks link' do
      before do
        post '/log_in', params
        post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=>"An afternoon breeze"}}},
                          email: "invited_user@email.com"
      end

      it 'should give invited friend a session' do
        get "#{response.header['Location']}?user=#{user.friends.last.password_salt}"
        expect(session[:user_id]).to eq(user.friends.last.id)
      end

      it "should redirect invited friend to the haiku author's create haiku form" do
        expect(response).to redirect_to(new_haiku_line_path(Haiku.last))
      end
    end
  end

  let(:haiku_with_lines) { FactoryGirl.create(:haiku_with_lines) }
  describe 'GET /haikus/edit' do
    before do
      post '/log_in', params
    end

    it "should render the edit form with haiku's lines in place" do
      get "/haikus/#{haiku_with_lines.id}/edit"
      expect(response).to have_http_status(200)
      expect(response).to render_template('edit')
      expect(response.body).to include(haiku_with_lines.lines.all.first.content)
      expect(response.body).to include(haiku_with_lines.lines.all.second.content)
      expect(response.body).to include(haiku_with_lines.lines.all.third.content)
    end
  end

  describe 'PATCH /haikus' do
    before do
      post '/log_in', params
    end

    it "should update haiku with new line content" do
      patch "/haikus/#{haiku_with_lines.id}", update_params
      expect(haiku_with_lines.lines.all.first.content).to eq("updated first line")
      expect(haiku_with_lines.lines.all.second.content).to eq("updated second line")
      expect(haiku_with_lines.lines.all.third.content).to eq("updated third line")
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(haiku_path(haiku_with_lines))
    end

    context "when haiku is written with no friends" do
      it "should show standard flash message" do
        patch "/haikus/#{haiku_with_lines.id}", update_params_with_same_user_id
        expect(flash[:notice]).to eq("Your haiku is completed")
      end
    end

    # context "when haiku is written with a friend" do
    # end

    context "when haiku is written with two friends" do
      it "should show a flash message with friend's email" do
        patch "/haikus/#{haiku_with_lines.id}", update_params
        expect(flash[:notice]).to eq("Your haiku is completed, and a copy of it was sent to #{User.where(id: haiku_with_lines.lines.all.first.user_id).first.email} and #{User.where(id: haiku_with_lines.lines.all.second.user_id).first.email}")
      end
    end

  end

  describe 'GET /haikus/:id' do
    it "should show completed haiku" do
      get "/haikus/#{haiku_with_lines.id}"
      expect(response).to have_http_status(200)
      expect(response).to render_template('show')
      expect(response.body).to include(haiku_with_lines.lines.all.first.content)
      expect(response.body).to include(haiku_with_lines.lines.all.second.content)
      expect(response.body).to include(haiku_with_lines.lines.all.third.content)
    end
  end
end
