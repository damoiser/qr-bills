require 'i18n'
require 'fileutils'
require 'qr-bills/qr-prawn-layout'
require 'qr-bills/qr-params'

RSpec.configure do |config|
  config.before(:each) do
    @params = QRParams.get_qr_params
    @params[:fonts][:eot] = "../web/assets/fonts/LiberationSans-Regular.eot"
    @params[:fonts][:woff] = "../web/assets/fonts/LiberationSans-Regular.woff"
    @params[:fonts][:ttf] = "../web/assets/fonts/LiberationSans-Regular.ttf"
    @params[:fonts][:svg] = "../web/assets/fonts/LiberationSans-Regular.svg"
    @params[:locales][:path] = "config/locales/"
    @params[:qrcode_format] = 'png'
    @params[:bill_params][:creditor][:iban] = "CH9300762011623852957"
    @params[:bill_params][:creditor][:address][:type] = "S"
    @params[:bill_params][:creditor][:address][:name] = "Compagnia di assicurazione forma & scalciante"
    @params[:bill_params][:creditor][:address][:line1] = "Via cantonale"
    @params[:bill_params][:creditor][:address][:line2] = "24"
    @params[:bill_params][:creditor][:address][:postal_code] = "3000"
    @params[:bill_params][:creditor][:address][:town] = "Lugano"
    @params[:bill_params][:creditor][:address][:country] = "CH"
    @params[:bill_params][:amount] = 12345.15
    @params[:bill_params][:currency] = "CHF"
    @params[:bill_params][:debtor][:address][:type] = "S"
    @params[:bill_params][:debtor][:address][:name] = "Foobar Barfoot"
    @params[:bill_params][:debtor][:address][:line1] = "Via cantonale"
    @params[:bill_params][:debtor][:address][:line2] = "25"
    @params[:bill_params][:debtor][:address][:postal_code] = "3001"
    @params[:bill_params][:debtor][:address][:town] = "Comano"
    @params[:bill_params][:debtor][:address][:country] = "CH"
    @params[:bill_params][:reference] = "RF89MTR81UUWZYO48NY55NP3"
    @params[:bill_params][:reference_type] = "SCOR"
    @params[:bill_params][:additionally_information] = "pagamento riparazione monopattino"

    I18n.load_path << File.join(@params[:locales][:path], "qrbills.it.yml")
    I18n.load_path << File.join(@params[:locales][:path], "qrbills.en.yml")
    I18n.load_path << File.join(@params[:locales][:path], "qrbills.de.yml")
    I18n.load_path << File.join(@params[:locales][:path], "qrbills.fr.yml")
    I18n.default_locale = :it
  end
end

RSpec.describe "QRPRAWNLayout" do
  before do
    FileUtils.mkdir_p "#{Dir.pwd}/tmp/"
    File.delete filepath if File.exist?(filepath)
  end

  let(:filepath) { "#{Dir.pwd}/tmp/prawn-layout.pdf" }

  describe "layout generation" do
    before do
      @params[:qrcode_format] = 'png'
    end

    it "successfully generates prawn/ruby layout + qr code" do
      expect{QRPRAWNLayout.create(@params)}.not_to raise_error
    end

    it "generates legacy png qrcode" do
      @params[:qrcode_format] = nil
      @params[:qrcode_filepath] = "#{Dir.pwd}/tmp/qrcode-html.png"

      IO.binwrite("#{Dir.pwd}/tmp/prawn-layout.pdf", QRPRAWNLayout.create(@params).to_s)
      expect(File.exist?(filepath)).to be_truthy
      expect(File.exist?("#{Dir.pwd}/tmp/qrcode-html.png")).to be_truthy
    end

    it "generates png qrcode" do
      prawn_output = QRPRAWNLayout.create(@params).to_s
      IO.binwrite(filepath, prawn_output)
      expect(File.exist?(filepath)).to be_truthy

      # TODO
      # Parse generated PDF and determine if it has QR code as ChunkyPNG
      # expect(prawn_output).to include("data:image/png;base64,")
    end

    it "generates svg qrcode" do
      @params[:qrcode_format] = 'svg'

      prawn_output = QRPRAWNLayout.create(@params).to_s
      IO.binwrite(filepath, prawn_output)
      expect(File.exist?(filepath)).to be_truthy

      # TODO
      # Parse generated PDF and determine if it has QR code as svg
      # expect(prawn_output).to include("data:image/svg+xml;charset=utf-8,")
    end

    it "does not overwrite locale" do
      @params[:bill_params][:language] = :de

      QRPRAWNLayout.create(@params)

      expect(I18n.locale).to be :it
    end

    it "rounds correctly (1)" do
      prawn_output = QRPRAWNLayout.create(@params).to_s

      IO.binwrite(filepath, prawn_output)
      expect(File.exist?(filepath)).to be_truthy

      # TODO
      # expect(prawn_output).to include("12345.15")
    end

    it "rounds correctly (2)" do
      @params[:bill_params][:amount] = 12345.1

      prawn_output = QRPRAWNLayout.create(@params).to_s

      IO.binwrite(filepath, prawn_output)
      expect(File.exist?(filepath)).to be_truthy

      # TODO
      # expect(prawn_output).to include("12345.10")
    end

    it "rounds correctly (3)" do
      @params[:bill_params][:amount] = 12345.10

      prawn_output = QRPRAWNLayout.create(@params).to_s

      IO.binwrite(filepath, prawn_output)
      expect(File.exist?(filepath)).to be_truthy

      # TODO
      # expect(prawn_output).to include("12345.10")
    end
  end
end
