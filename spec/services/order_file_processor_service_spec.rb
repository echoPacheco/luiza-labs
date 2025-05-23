require 'rails_helper'

RSpec.describe OrderFileProcessorService do
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'test_orders.txt') }
  let(:file) { Rack::Test::UploadedFile.new(file_path, 'text/plain') }

  before do
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, file_content)
  end

  after do
    File.delete(file_path) if File.exist?(file_path)
  end

  context 'com um único registro' do
    let(:file_content) { '0000000041                           Dr. Dexter Rolfson00000004340000000005      288.5120210527' }

    it 'processa o arquivo e cria registros' do
      expect {
        described_class.new(file).call
      }.to change(User, :count).by(1)
       .and change(Order, :count).by(1)
       .and change(Product, :count).by(1)
    end
 
    it 'cria os dados com os atributos corretos' do
      described_class.new(file).call

      user = User.find_by(user_id: 41)
      expect(user.name).to eq('Dr. Dexter Rolfson')

      order = Order.find_by(order_id: 434)
      expect(order.total).to eq(288.51)
      expect(order.date).to eq(Date.new(2021, 5, 27))

      product = Product.find_by(order_id: order.id)
      expect(product.product_id).to eq(5)
      expect(product.value).to eq(288.51)
    end
  end

  context 'com múltiplas linhas e usuários duplicados' do
    let(:file_content) do
      [
        '0000000070                              Palmer Prosacco00000007530000000003     1836.7420210308',
        '0000000070                              Palmer Prosacco00000005230000000003      586.7420210903',
        '0000000075                                  Bobbie Batz00000007980000000002     1578.5720211116'
      ].join("\n")
    end    

    it 'cria usuários, pedidos e produtos corretamente sem duplicar usuários' do
      expect {
        described_class.new(file).call
      }.to change(User, :count).by(2)
       .and change(Order, :count).by(3)
       .and change(Product, :count).by(3)

      expect(User.where(user_id: 70).count).to eq(1)
      expect(User.where(user_id: 75).count).to eq(1)
    end

    it 'não recria os dados se rodar novamente com o mesmo arquivo' do
      described_class.new(file).call

      expect {
        described_class.new(file).call
      }.to change(Product, :count).by(3)
        .and change(User, :count).by(0)
        .and change(Order, :count).by(0)
    end
  end
end
