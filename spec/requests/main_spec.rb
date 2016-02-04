require 'rails_helper'

describe 'main', type: :request do

  it 'renders landing page' do
    get '/'
    expect(response).to have_http_status(200)
    expect(response).to render_template('index')
  end
end
