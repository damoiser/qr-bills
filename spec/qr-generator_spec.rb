require 'qr-bills'
require 'fileutils'
require 'qr-bills/qr-generator'

RSpec.describe QRGenerator do
  before do
    FileUtils.mkdir_p "#{Dir.pwd}/tmp/"
    File.delete filepath if File.exist?(filepath)
  end

  let(:filepath) { "#{Dir.pwd}/tmp/qrcode.png" }
  let(:params) do
    QRParams.get_qr_params.tap do |params_hash|
      params_hash[:bill_params][:creditor][:iban] = "CH93 0076 2011 6238 5295 7"
      params_hash[:bill_params][:creditor][:address][:type] = "S"
      params_hash[:bill_params][:creditor][:address][:name] = "Compagnia di assicurazione forma & scalciante"
      params_hash[:bill_params][:creditor][:address][:line1] = "Via cantonale"
      params_hash[:bill_params][:creditor][:address][:line2] = "24"
      params_hash[:bill_params][:creditor][:address][:postal_code] = "3000"
      params_hash[:bill_params][:creditor][:address][:town] = "Lugano"
      params_hash[:bill_params][:creditor][:address][:country] = "CH"
      params_hash[:bill_params][:amount] = 12345.15
      params_hash[:bill_params][:currency] = "CHF"
      params_hash[:bill_params][:debtor][:address][:type] = "S"
      params_hash[:bill_params][:debtor][:address][:name] = "Foobar Barfoot"
      params_hash[:bill_params][:debtor][:address][:line1] = "Via cantonale"
      params_hash[:bill_params][:debtor][:address][:line2] = "25"
      params_hash[:bill_params][:debtor][:address][:postal_code] = "3001"
      params_hash[:bill_params][:debtor][:address][:town] = "Comano"
      params_hash[:bill_params][:debtor][:address][:country] = "CH"
      params_hash[:bill_params][:reference] = "RF89MTR81UUWZYO48NY55NP3"
      params_hash[:bill_params][:reference_type] = "SCOR"
      params_hash[:bill_params][:additionally_information] = "pagamento riparazione monopattino"
    end
  end

  describe "qrcode generation" do
    it "generates successfully a qr image" do
      params[:qrcode_format] = 'qrcode_png'

      expect(File.exist?(filepath)).to be_falsy
      expect{QRGenerator.create(params, filepath)}.not_to raise_error
      expect(File.exist?(filepath)).to be_truthy
    end

    it "generates a png image" do
      params[:qrcode_format] = 'png'

      png = QRGenerator.create(params)
      expect(png.class).to be(ChunkyPNG::Image)
    end

    it "generates a svg string" do
      params[:qrcode_format] = 'svg'

      svg = QRGenerator.create(params)
      File.write('tmp/qrcode.svg', svg)
      file = File.open('spec/fixtures/qrcode.svg').read
      expect(svg).to eq(file)
    end
  end
end
