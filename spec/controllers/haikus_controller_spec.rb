require 'rails_helper'

RSpec.describe HaikusController, type: :controller do

  describe 'GET new' do
    it 'has a 200 status code with template' do
      get :new
      expect(response.status).to eq(200)
      expect(response).to render_template('new')
    end
  end

  describe 'POST create' do

    it 'adds a new haiku with line content' do
      expect {
        post :create, haiku: {"lines_attributes"=>{"0"=>{"content"=>"An afternoon breeze"}}}
      }.to change(Haiku, :count).by(1)
      expect(response).to redirect_to(root_url)
    end

    it 'adds a new haiku without line content' do
      expect {
        post :create, haiku: {"lines_attributes"=>{"0"=>{"content"=>""}}}
      }.to_not change(Haiku, :count)
      expect(response).to render_template('new')
    end
  end
end
