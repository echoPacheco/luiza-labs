require 'rails_helper'

RSpec.describe 'Api::Orders', type: :request do
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'upload_test.txt') }
  let(:file) { fixture_file_upload(file_path, 'text/plain') }
  let(:file_content) do
    [
      '0000000070                              Palmer Prosacco00000007530000000003     1836.7420210308',
      '0000000075                                  Bobbie Batz00000007980000000002     1578.5720211116',
      '0000000017                              Ethan Langworth00000001690000000000      865.1820210409',
      '0000000077                         Mrs. Stephen Trantow00000008440000000005     1288.7720211127',
      '0000000077                         Mrs. Stephen Trantow00000008320000000006      961.3720210513',
    ].join("\n")
  end

  before do
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, file_content)
  end

  after do
    File.delete(file_path) if File.exist?(file_path)
  end

  describe 'POST /api/orders/upload' do
    it 'retorna sucesso ao processar arquivo válido e cria os dados corretamente' do
      expect {
        post '/api/orders/upload', params: { file: file }
      }.to change(User, :count).by(4)
       .and change(Order, :count).by(5)
       .and change(Product, :count).by(5)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Order file processed successfully')
    end

    it 'retorna erro se nenhum arquivo for enviado' do
      post '/api/orders/upload'
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['error']).to eq('No file provided')
    end
  end

  describe 'GET /api/orders' do
    before do
      post '/api/orders/upload', params: { file: file }
    end

    it 'retorna pedidos agrupados por usuário' do
      get '/api/orders'
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.size).to eq(4) # 4 usuários distintos
    end

    it 'filtra por order_id' do
      get '/api/orders', params: { order_id: 798 }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first['orders'].first['order_id']).to eq(798)
    end

    it 'filtra por intervalo de datas' do
      get '/api/orders', params: {
        start_date: '2021-03-01',
        end_date: '2021-03-31'
      }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first['orders'].first['date']).to eq('2021-03-08')
    end
  end
end
